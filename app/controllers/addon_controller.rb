# frozen_string_literal: true

class AddonController < ActionController::API
  attr_reader :bitrise_client, :request_payload, :jwt_token

  before_action :verify_service_token
  before_action :retrieve_request_payload

  def provision
    bitrise_client = Bitrise::Client.new(
      base_url: ENV['AUTH_BASE_URL'],
      realm: ENV['AUTH_REALM'],
      client_id: ENV['AUTH_CLIENT_ID'],
      client_secret: ENV['AUTH_CLIENT_SECRET']
    )

    begin
      auth_obj = bitrise_client.acquire_access_token_object(exchange_token: jwt_token)
    rescue StandardError => e
      return render json: { error: e.message }.to_json, status: :unauthorized
    end

    begin
      app = Datastore.provision_addon_for_app!(request_payload['app_slug'],
                                               request_payload['app_title'],
                                               request_payload['plan'],
                                               auth_obj[:access_token],
                                               auth_obj[:refresh_token])
    rescue StandardError => e
      return render json: { error: e.to_s }.to_json, status: :bad_request
    end

    render json: { envs: [{ "key": 'BITRISE_SAMPLE_ADDON_ACCESS_TOKEN', "value": app[:access_token] }] }.to_json, status: :ok
  end

  def delete
    Datastore.deprovision_addon_for_app(params[:app_slug])
    render json: { message: 'ok' }.to_json, status: :ok
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

  def retrieve_request_payload
    request.body.rewind

    raw_body = request.body.read
    @request_payload = if raw_body.present?
                         JSON.parse(request.body.read)
                       else
                         JSON.parse('{}')
                       end
  end

  def config_token_present?
    ENV['ADDON_TOKEN'] == request.headers['HTTP_AUTHORIZATION']
  end
end
