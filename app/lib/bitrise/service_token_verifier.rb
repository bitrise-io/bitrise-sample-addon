# frozen_string_literal: true

module Bitrise
  class ServiceTokenVerifier
    def initialize(jwt_token_verifier:, jwks_cache_timeout:)
      @jwks_cache_timeout = jwks_cache_timeout
      @jwt_token_verifier = jwt_token_verifier

      @mutex = Mutex.new
      reset_jwks_updated_at
    end

    def valid?(token:, audiences: [])
      return false if token.blank?

      renew_jwks_if_expired

      return false if @jwt_token_verifier.verify(token, aud: audiences).nil?

      true
    end

    private

    def renew_jwks_if_expired
      @mutex.synchronize do
        return if @jwks_updated_at + @jwks_cache_timeout >= current_time_in_secs

        @jwt_token_verifier.jwks_acquirer.force_renew

        reset_jwks_updated_at
      end
    end

    def reset_jwks_updated_at
      @jwks_updated_at = current_time_in_secs
    end

    def current_time_in_secs
      Time.current.to_i
    end
  end
end
