# frozen_string_literal: true

class AddonController < ActionController::API
  attr_reader :bitrise_client, :request_payload

  before_action :authentication_header_resent?
  before_action :retrieve_request_payload

  def provision
    bitrise_client = Bitrise::Client.new(
      base_url: ENV['AUTH_BASE_URL'],
      realm: ENV['AUTH_REALM'],
      client_id: ENV['AUTH_CLIENT_ID'],
      client_secret: ENV['AUTH_CLIENT_SECRET']
    )

    begin
      auth_obj = bitrise_client.acquire_access_token_object(exchange_token: request.env['HTTP_AUTHORIZATION'])
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
    return render status: :unauthorized unless config_token_present?

    Datastore.deprovision_addon_for_app(params[:app_slug])
    render json: { message: 'ok' }.to_json, status: :ok
  end

  private

  def authentication_header_resent?
    render :unauthorized if request.headers['HTTP_AUTHORIZATION'].blank?
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
