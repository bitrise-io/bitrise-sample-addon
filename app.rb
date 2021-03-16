require File.dirname(__FILE__) + '/data_store'
require File.dirname(__FILE__) + '/bitrise_client'
require File.dirname(__FILE__) + '/errors'
require 'sinatra/base'
require 'sinatra/reloader'

# App router class
class App < Sinatra::Base
  puts "Server listening on #{ENV['PORT']}"

  set :bind, '0.0.0.0'
  set :port, ENV['PORT']

  configure :development do
    register Sinatra::Reloader
  end
  Tilt.register Tilt::ERBTemplate, 'html.erb'

  addon_token = ENV['ADDON_TOKEN']
  sso_secret = ENV['ADDON_SSO_SECRET']
  data_store = DataStore.new

  bitrise_client = BitriseClient.new(
    base_url: ENV['AUTH_BASE_URL'], 
    realm: ENV['AUTH_REALM'], 
    client_id: ENV['AUTH_CLIENT_ID'], 
    client_secret: ENV['AUTH_CLIENT_SECRET']
  )

  before(%r{/(provision)/*\w*}) do
    # checking the Authentication request header
    puts "Auth"

    halt 401, { message: 'unauthorized' }.to_json if request.env['HTTP_AUTHENTICATION'].blank?
    puts "Auth OK"
  end

  get '/' do
    'Welcome to Bitrise Sample Addon'
  end

  post '/provision' do
    puts "Provisioning"

    request.body.rewind
    request_payload = JSON.parse(request.body.read)
    begin
      auth_obj = bitrise_client.acquire_access_token_object(exchange_token: request.env['HTTP_AUTHENTICATION'])
      puts "auth_obj"
      puts auth_obj.inspect


      app = data_store.provision_addon_for_app!(request_payload['app_slug'], request_payload['app_title'],
                                                request_payload['plan'], SecureRandom.hex(32))
    rescue StandardError => e
      halt 400, { message: e.to_s }.to_json
    end
    { envs: [{ "key": 'BITRISE_SAMPLE_ADDON_ACCESS_TOKEN', "value": app[:api_token] }] }.to_json
  end

  put '/provision/:app_slug' do
    halt 404, { message: 'app cannot be found' }.to_json if data_store.get_app(params[:app_slug]).nil?
    request.body.rewind
    request_payload = JSON.parse(request.body.read)

    begin
      data_store.update_plan!(params[:app_slug], request_payload['plan'])
      { message: 'ok' }.to_json
    rescue NotFoundError => e
      halt 404, { message: e.to_s }.to_json
    rescue StandardError => e
      halt 400, { message: e.to_s }.to_json
    end
  end

  delete '/provision/:app_slug' do
    data_store.deprovision_addon_for_app(params[:app_slug])
    return { message: 'ok' }.to_json
  end

  post '/login' do
    app = data_store.get_app(params[:app_slug])
    halt 400, { message: 'no app provisioned with this slug' }.to_json if app.nil?
    calc_sso_token = Digest::SHA1.hexdigest "#{params[:app_slug]}:#{sso_secret}:#{params['timestamp']}"

    halt 401, { message: 'unauthorized' }.to_json if params['token'] != calc_sso_token
    @app = app
    erb :dashboard
  end

  get '/ascii-art/:app_slug' do
    app = data_store.get_app(params[:app_slug])

    # checking the Authentication request header
    authenticated = app&.[](:api_token) == request.env['HTTP_AUTHENTICATION']
    halt 401, { message: 'unauthorized' }.to_json unless authenticated

    begin
      data_store.check_limit!(params[:app_slug])
    rescue NotFoundError => e
      halt 404, { message: e.to_s }.to_json
    rescue StandardError => e
      halt 400, { message: e.to_s }.to_json
    end

    file = File.open("assets/art#{Random.rand(1..3)}.txt")
    bitbot = []
    file.each do |line|
      bitbot = bitbot.concat([line.to_s])
    end
    bitbot.join
  end
end
