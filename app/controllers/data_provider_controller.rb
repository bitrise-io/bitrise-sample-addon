# frozen_string_literal: true

class DataProviderController < ActionController::API
  attr_reader :app

  before_action :verify_service_token
  before_action :retrieve_app

  def ascii_provider
    begin
      Datastore.check_limit!(params[:app_slug])
    rescue StandardError => ex
      return render json: { error: ex.to_s }.to_json, status: :bad_request
    end

    location = File.dirname(__FILE__)
    file = File.open("#{location}/../../assets/art#{Random.rand(1..3)}.txt")
    bitbot = []
    file.each do |line|
      bitbot = bitbot.concat([line.to_s])
    end
    bitbot.join

    render plain: bitbot
  end

  private

  def verify_service_token
    auth_header = request.headers['HTTP_AUTHORIZATION']
    return render plain: 'unauthorized', status: :unauthorized if auth_header.blank?

    token = get_token_from_header(auth_header)
    valid = Service_token_verifier.valid?(
      token: token,
      audiences: []
    )

    return render plain: 'unauthorized', status: :unauthorized if !valid

    @jwt_token = token
  end

  def get_token_from_header(auth_header)
    auth_header.sub('Bearer ', '')
  end

  def retrieve_app
    @app = Datastore.get_app(params[:app_slug])
    if @app.nil?
      return render json: { error: 'no app provisioned with this slug' }.to_json, status: :bad_request
    end
  end
end
