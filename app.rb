require File.dirname(__FILE__) + '/data_store'
require File.dirname(__FILE__) + '/errors'
require 'sinatra/base'
require 'sinatra/reloader'

class App < Sinatra::Base
  set :bind, '0.0.0.0'

  configure :development do
    register Sinatra::Reloader
  end
  Tilt.register Tilt::ERBTemplate, 'html.erb'

  addon_token = ENV['ADDON_TOKEN']
  sso_secret = ENV['ADDON_SSO_SECRET']
  data_store = DataStore.new

  before '/login' do
    @beam_version = ENV['BITRISE_BEAM_VERSION']
  end

  before /\/(provision)[\/]*[\w]*/ do
    # checking the Authentication request header
    if request.env['HTTP_AUTHENTICATION'] != addon_token
      halt 401, {message: 'unauthorized'}.to_json
    end
  end

  get '/' do
    'Welcome to Bitrise Sample Addon'
  end

  post '/provision' do
    request.body.rewind
    request_payload = JSON.parse(request.body.read)
    begin
      app = data_store.provision_addon_for_app!(request_payload['app_slug'], request_payload['plan'], SecureRandom.hex(32))
    rescue StandardError => ex
      halt 400, {message: ex.to_s}.to_json
    end
    {envs: [{"key": "BITRISE_SAMPLE_ADDON_ACCESS_TOKEN", "value": app[:api_token]}]}.to_json
  end

  put '/provision/:app_slug' do
    if data_store.get_app(params[:app_slug]) == nil
      halt 404, {message: 'app cannot be found'}.to_json
    end
    request.body.rewind
    request_payload = JSON.parse(request.body.read)

    begin
      data_store.update_plan!(params[:app_slug], request_payload['plan'])
      {message: 'ok'}.to_json
    rescue NotFoundError => ex
      halt 404, {message: ex.to_s}.to_json
    rescue StandardError => ex
      halt 400, {message: ex.to_s}.to_json
    end
  end

  delete '/provision/:app_slug' do
    data_store.deprovision_addon_for_app(params[:app_slug])
    return {message: 'ok'}.to_json
  end

  post '/login' do
    app = data_store.get_app(params[:app_slug])
    if app == nil
      halt 400, {message: 'no app provisioned with this slug'}.to_json
    end
    calc_sso_token = Digest::SHA1.hexdigest "#{params[:app_slug]}:#{sso_secret}:#{params['timestamp']}"

    if params['token'] != calc_sso_token
      halt 401, {message: "unauthorized"}.to_json
    end
    @app_slug = params[:app_slug]
    @app = app
    erb :dashboard
  end

  get '/ascii-art/:app_slug' do
    app = data_store.get_app(params[:app_slug])

    # checking the Authentication request header
    authenticated = app&.[](:api_token) == request.env['HTTP_AUTHENTICATION']
    if !authenticated
      halt 401, {message: 'unauthorized'}.to_json
    end

    begin
      data_store.check_limit!(params[:app_slug])
    rescue NotFoundError => ex
      halt 404, {message: ex.to_s}.to_json
    rescue StandardError => ex
      halt 400, {message: ex.to_s}.to_json
    end

    file = File.open("assets/art#{Random.rand(1..3)}.txt")
    bitbot = []
    file.each do |line|
      bitbot = bitbot.concat([line.to_s])
    end
    bitbot.join()
  end
end