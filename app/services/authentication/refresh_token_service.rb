# frozen_string_literal: true

require 'digest'
require 'securerandom'

module Authentication
  # Rotates opaque refresh credentials and tracks their revocation families.
  class RefreshTokenService
    LIFETIME = 30.days
    IssuedToken = Struct.new(:token, :session, keyword_init: true)

    class InvalidToken < StandardError; end
    class ReusedToken < InvalidToken; end

    def self.issue(user, now: Time.current)
      token = generate_token
      session = user.refresh_sessions.create!(
        token_digest: digest(token),
        family_id: SecureRandom.uuid,
        expires_at: now + LIFETIME
      )

      IssuedToken.new(token: token, session: session)
    end

    def self.rotate(token, now: Time.current)
      session = RefreshSession.find_by(token_digest: digest(token))
      raise InvalidToken, 'Invalid refresh token' unless session

      outcome, issued_token = rotate_in_transaction(session, now)
      raise ReusedToken, 'Refresh token reuse detected' if outcome == :reused
      raise InvalidToken, 'Invalid refresh token' unless issued_token

      issued_token
    rescue ActiveRecord::RecordNotFound
      raise InvalidToken, 'Invalid refresh token'
    end

    def self.revoke(token, now: Time.current)
      revoked = false
      RefreshSession.transaction do
        session = RefreshSession.find_by(token_digest: digest(token))
        if session
          revoke_family(session.family_id, now)
          revoked = true
        end
      end
      revoked
    end

    def self.digest(token)
      Digest::SHA256.hexdigest(token.to_s)
    end
    private_class_method :digest

    def self.generate_token
      SecureRandom.urlsafe_base64(64)
    end
    private_class_method :generate_token

    def self.revoke_family(family_id, now)
      RefreshSession.where(family_id: family_id, revoked_at: nil)
                    .find_each { |session| session.update!(revoked_at: now) }
    end
    private_class_method :revoke_family

    def self.rotate_locked(session, now)
      session.with_lock do
        session.reload
        rotate_state(session, now)
      end
    end
    private_class_method :rotate_locked

    def self.rotate_in_transaction(session, now)
      RefreshSession.transaction { rotate_locked(session, now) }
    end
    private_class_method :rotate_in_transaction

    def self.rotate_state(session, now)
      return reuse_token(session, now) if session.revoked_at
      return expire_token(session, now) if session.expires_at <= now

      session.update!(revoked_at: now)
      [:rotated, replacement_token(session)]
    end
    private_class_method :rotate_state

    def self.reuse_token(session, now)
      revoke_family(session.family_id, now)
      [:reused, nil]
    end
    private_class_method :reuse_token

    def self.expire_token(session, now)
      session.update!(revoked_at: now)
      [:invalid, nil]
    end
    private_class_method :expire_token

    def self.replacement_token(session)
      token = generate_token
      replacement = session.user.refresh_sessions.create!(
        token_digest: digest(token),
        family_id: session.family_id,
        expires_at: session.expires_at
      )
      IssuedToken.new(token: token, session: replacement)
    end
    private_class_method :replacement_token
  end
end
