# frozen_string_literal: true

require 'uri'

Rails.application.config.x.authentication.jwt_secret_key =
  ENV['JWT_SECRET_KEY'].presence || (Rails.application.secret_key_base unless Rails.env.production?)

Rails.application.config.x.authentication.allowed_origin =
  ENV['AUTH_ALLOWED_ORIGIN'].presence ||
  (Rails.env.test? ? 'http://www.example.com' : 'http://localhost:3000')

if Rails.env.production?
  missing_configuration = []
  missing_configuration << 'JWT_SECRET_KEY (at least 32 characters)' if
    Rails.application.config.x.authentication.jwt_secret_key.to_s.bytesize < 32
  missing_configuration << 'AUTH_ALLOWED_ORIGIN' if
    ENV['AUTH_ALLOWED_ORIGIN'].blank?

  unless missing_configuration.empty?
    raise "Missing required authentication configuration: #{missing_configuration.join(', ')}"
  end

  begin
    origin = URI.parse(Rails.application.config.x.authentication.allowed_origin)
    unless %w[http https].include?(origin.scheme) && origin.host.present? &&
           origin.path.blank? && origin.query.blank? && origin.fragment.blank?
      raise URI::InvalidURIError
    end
  rescue URI::InvalidURIError
    raise 'AUTH_ALLOWED_ORIGIN must be an HTTP(S) origin without a path, query, or fragment'
  end
end
