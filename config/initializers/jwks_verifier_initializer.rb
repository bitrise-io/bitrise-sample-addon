website_services_jwks_acquirer = Bitrise::JwksAcquirer.new(
  site: ENV['AUTH_BASE_URL'],
  realm: ENV['AUTH_REALM'],
)

website_services_token_validator = Bitrise::JwtTokenVerifier.new(
  jwks_acquirer: website_services_jwks_acquirer
)

Service_token_verifier = Bitrise::ServiceTokenVerifier.new(
  jwt_token_verifier: website_services_token_validator,
  jwks_cache_timeout: 2.hours.to_i
)