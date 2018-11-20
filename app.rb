require File.dirname(__FILE__) + '/data_store'
require 'sinatra/base'
require 'sinatra/reloader'

class App < Sinatra::Base
  set :bind, '0.0.0.0'

  configure :development do
    register Sinatra::Reloader
  end

  addon_token = "development_token"
  data_store = DataStore.new

  get '/' do
    'Welcome to Bitrise Sample Addon'
  end

  post '/provision' do
    if addon_token != request.env['HTTP_AUTHENTICATION']
      status 401
      return {message: 'unauthorized'}.to_json
    end
    request.body.rewind
    request_payload = JSON.parse(request.body.read)
    access_token = data_store.provision_addon_for_app(request_payload['app_slug'], request_payload['plan'], SecureRandom.hex(32))
    {envs: [{"key": "ACCESS_TOKEN", "value": access_token}]}.to_json
  end

  put '/provision/:app_slug' do
    if addon_token != request.env['HTTP_AUTHENTICATION']
      status 401
      return {message: 'unauthorized'}.to_json
    end
    request.body.rewind
    request_payload = JSON.parse(request.body.read)

    begin
      data_store.update_plan!(params['app_slug'], request_payload["plan"])
      {message: 'ok'}.to_json
    rescue StandardError => ex
      status 400
      return {message: ex.to_s}.to_json
    end
  end

  delete '/provision/:app_slug' do
    if addon_token != request.env['HTTP_AUTHENTICATION']
      status 401
      return {message: 'unauthorized'}.to_json
    end

    data_store.deprovision_addon_for_app(params['app_slug'])
    return {message: 'ok'}.to_json
  end

  post '/login' do
    sso_token = 'development-sso-secret'
    calc_sso_token = Digest::SHA1.hexdigest "#{params['app_slug']}:#{sso_token}:#{params['timestamp']}"
    if params['token'] != calc_sso_token
      status 401
      return {message: "#{params['token']}"}.to_json
    end

    return "<!DOCTYPE html><html><body><h1>Hello Bitrise Addon Developer!</h1></body></html>"
  end

  get '/ascii-art/:app_slug' do
    if !data_store.authenticate(params['app_slug'], request.env['HTTP_AUTHENTICATION'])
      status 401
      return {message: 'unauthorized'}.to_json
    end

    begin
      data_store.check_limit!(params['app_slug'])
    rescue StandardError => ex
      status 400
      return {message: ex.to_s}.to_json
    end

    file = File.open('assets/bitbot.txt')
    bitbot = []
    file.each do |line|
      bitbot = bitbot.concat([line.to_s])
    end
    bitbot.join()
  end
end