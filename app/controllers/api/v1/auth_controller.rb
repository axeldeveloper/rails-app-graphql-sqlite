# frozen_string_literal: true

module Api
  module V1
    # Handles registration, login, refresh, and logout requests.
    class AuthController < Api::ApplicationApiController
      before_action :verify_browser_origin!, only: %i[refresh logout]

      def register
        user = User.new(registration_params)

        User.transaction do
          user.save!
          issued_refresh_token = Authentication::RefreshTokenService.issue(user)
          issue_authentication_response(user, issued_refresh_token, status: :created)
        end
      rescue ActiveRecord::RecordInvalid => e
        render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
      rescue ActiveRecord::RecordNotUnique
        render json: { errors: ['Email has already been taken'] }, status: :unprocessable_entity
      end

      def login
        user = User.find_by(email: normalized_email)
        unless params[:password].present? && user&.authenticate(params[:password])
          return render json: { error: 'Invalid email or password' }, status: :unauthorized
        end

        issued_refresh_token = Authentication::RefreshTokenService.issue(user)
        issue_authentication_response(user, issued_refresh_token)
      end

      def refresh
        issued_refresh_token = Authentication::RefreshTokenService.rotate(cookies[:refresh_token])
        issue_authentication_response(issued_refresh_token.session.user, issued_refresh_token)
      rescue Authentication::RefreshTokenService::InvalidToken
        clear_refresh_cookie
        render json: { error: 'Invalid refresh token' }, status: :unauthorized
      end

      def logout
        Authentication::RefreshTokenService.revoke(cookies[:refresh_token]) if cookies[:refresh_token].present?
        clear_refresh_cookie
        head :no_content
      end

      private

      def registration_params
        params.permit(:email, :password)
      end

      def normalized_email
        params[:email].to_s.strip.downcase
      end

      def issue_authentication_response(user, issued_refresh_token, status: :ok)
        write_refresh_cookie(issued_refresh_token)
        render json: authentication_payload(user), status: status
      end

      def authentication_payload(user)
        {
          user: { id: user.id, email: user.email },
          access_token: Authentication::AccessToken.issue(user)
        }
      end

      def write_refresh_cookie(issued_refresh_token)
        cookies[:refresh_token] = {
          value: issued_refresh_token.token,
          httponly: true,
          secure: Rails.env.production?,
          same_site: :lax,
          path: '/api/v1/auth',
          expires: issued_refresh_token.session.expires_at
        }
      end

      def clear_refresh_cookie
        cookies.delete(
          :refresh_token,
          path: '/api/v1/auth',
          secure: Rails.env.production?,
          same_site: :lax
        )
      end

      def verify_browser_origin!
        allowed_origin = Rails.application.config.x.authentication.allowed_origin
        return if request.headers['Origin'] == allowed_origin

        render json: { error: 'Invalid request origin' }, status: :forbidden
      end
    end
  end
end
