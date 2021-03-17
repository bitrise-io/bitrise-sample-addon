# frozen_string_literal: true

module Bitrise
  class JwksAcquirer
    attr_reader :site, :realm

    def initialize(site:, realm:)
      @site = site
      @realm = realm
      @jwks_hash = nil
      @mutex = Mutex.new
    end

    def acquire_jwks
      @mutex.synchronize do
        if @jwks_hash.nil?
          begin
            @jwks_hash = download_jwks
          rescue StandardError => ex
            Rails.logger.error " [!] Exception: alerting JwksAcquirer error: #{ex}"

            raise ex
          end
        end

        return @jwks_hash
      end
    end

    def force_renew
      @mutex.synchronize do
        @jwks_hash = nil
      end

      acquire_jwks
    end

    private

    def download_jwks
      response = Faraday.get jwks_url

      JSON.parse(response.body, symbolize_names: true)
    end

    def jwks_url
      "#{site}/auth/realms/#{realm}/protocol/openid-connect/certs"
    end
  end
end
