# frozen_string_literal: true

class UserController < ActionController::API
  def login
    sso_secret = ENV['ADDON_SSO_SECRET']

    app = Datastore.get_app(params[:app_slug])
    if app.nil?
      return render json: { error: 'no app provisioned with this slug' }.to_json, status: :bad_request
    end

    calc_sso_token = Digest::SHA1.hexdigest "#{params[:app_slug]}:#{sso_secret}:#{params['timestamp']}"

    if params['token'] != calc_sso_token
      return render status: :unauthorized
    end

    render json: app.to_json, status: :ok
  end
end
