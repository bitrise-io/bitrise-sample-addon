# frozen_string_literal: true

module Bitrise
  class Client
    attr_reader :base_url, :realm, :client_id, :client_secret

    def initialize(base_url:, realm:, client_id:, client_secret:)
      @base_url = base_url
      @realm = realm
      @client_id = client_id
      @client_secret = client_secret
    end

    def acquire_access_token_object(exchange_token:)
      if exchange_token.blank?
        return nil
      end

      form_data = {
        grant_type: 'urn:ietf:params:oauth:grant-type:token-exchange',
        client_id: client_id,
        client_secret: client_secret,
        subject_token: exchange_token,
        requested_token_type: 'urn:ietf:params:oauth:token-type:refresh_token'
      }

      resp = Faraday.post(auth_url, form_data,
                          'Content-Type' => 'application/x-www-form-urlencoded')

      response_body = JSON.parse(resp.body)

      if !resp.success?
        raise response_body['error_description']
      end

      {
        access_token: response_body['access_token'],
        expires_in: response_body['expires_in'],
        refresh_token: response_body['refresh_token'],
        scope: response_body['scope']
      }
    end

    private

    def auth_url
      "#{base_url}/auth/realms/#{realm}/protocol/openid-connect/token"
    end
  end
end
