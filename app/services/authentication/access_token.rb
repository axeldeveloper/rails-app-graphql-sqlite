# frozen_string_literal: true

module Authentication
  # Issues and verifies short-lived JWT access credentials.
  class AccessToken
    ALGORITHM = 'HS256'
    LIFETIME = 15.minutes

    def self.issue(user, now: Time.current)
      payload = {
        sub: user.id.to_s,
        iat: now.to_i,
        exp: (now + LIFETIME).to_i
      }

      JWT.encode(payload, secret_key, ALGORITHM)
    end

    def self.authenticate(token, now: Time.current)
      payload, = JWT.decode(token, secret_key, true, algorithm: ALGORITHM, leeway: 0)
      return unless payload['exp'] && payload['sub'].present?
      return if payload['exp'].to_i <= now.to_i

      User.find_by(id: payload['sub'])
    rescue JWT::DecodeError, ArgumentError
      nil
    end

    def self.authenticate_header(header)
      match = /\ABearer\s+(.+)\z/i.match(header.to_s)
      authenticate(match[1]) if match
    end

    def self.secret_key
      Rails.application.config.x.authentication.jwt_secret_key
    end
    private_class_method :secret_key
  end
end
