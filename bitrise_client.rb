class BitriseClient
  attr_reader :base_url, :realm, :client_id, :client_secret

  def initialize(base_url:, realm:, client_id:, client_secret:)
    @base_url = base_url
    @realm = realm
    @client_id = client_id
    @client_secret = client_secret
  end

  def acquire_access_token_object(exchange_token:)
    puts 'exchange_token'
    puts exchange_token

    if exchange_token.blank?
      return nil
    end

    form_data = {
      grant_type: 'urn:ietf:params:oauth:grant-type:token-exchange',
      client_id: client_id,
      client_secret: client_secret,
      subject_token: exchange_token,
      requested_token_type: 'urn:ietf:params:oauth:token-type:refresh_token'
    }.to_json

    puts 'form_data'
    puts form_data

    resp = Faraday.post(auth_url, form_data,
                        'Content-Type' => 'application/x-www-form-urlencoded')

    puts 'resp'
    puts resp

    {
      access_token: resp.body['access_token'],
      expires_in: resp.body['expires_in'],
      refresh_token: resp.body['refresh_token'],
      scope: resp.body['scope']
    }
  end

  private

  def auth_url
    "#{base_url}/auth/realms/#{realm}/protocol/openid-connect/token"
  end
end
