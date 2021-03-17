# frozen_string_literal: true

require 'jwt'

module Bitrise
  class JwtTokenVerifier
    attr_reader :jwks_acquirer

    def initialize(jwks_acquirer:)
      @jwks_acquirer = jwks_acquirer
    end

    def verify(token, options = {})
      opts = {
        verify_iss: true,
        algorithm: 'RS256',
        iss: issuer_url
      }
      opts.merge!(options)

      opts['verify_aud'] = false
      if options.key?(:aud)
        opts['verify_aud'] = !options[:aud].empty?
      end

      opts[:jwks] = jwks_acquirer.acquire_jwks
      begin
        JWT.decode token, nil, true, opts
      rescue JWT::VerificationError => ex
        Rails.logger.error " [!] Exception: alerting JwtTokenVerifier error: #{ex}"

        raise ex
      end
    end

    private

    def issuer_url
      "#{jwks_acquirer.site}/auth/realms/#{jwks_acquirer.realm}"
    end
  end
end
