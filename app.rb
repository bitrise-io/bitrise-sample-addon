require File.dirname(__FILE__) + '/data_store'
require 'sinatra/base'
require 'sinatra/reloader'

class App < Sinatra::Base
  set :bind, '0.0.0.0'

  configure :development do
    register Sinatra::Reloader
  end

  data_store = DataStore.new

  get '/' do
    'Welcome to Bitrise Sample Addon'
  end

  post '/provision' do
    request.body.rewind
    request_payload = JSON.parse(request.body.read)
    access_token = data_store.provision_addon_for_app(request_payload['app_slug'], request_payload['plan'], SecureRandom.hex(32))
    {envs: [{"ACCESS_TOKEN": access_token}]}.to_json
  end

  patch '/:app_slug/provision' do
    if !data_store.authenticate(params['app_slug'], request.env['HTTP_AUTHORIZATION'])
      error 401
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

  delete '/provision' do
  end

  post '/login' do
  end

  get '/:app_slug/ascii-art' do
    if !data_store.authenticate(params['app_slug'], request.env['HTTP_AUTHORIZATION'])
      error 401
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