# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength -- Keep the auth endpoint lifecycle scenarios together.
RSpec.describe 'Api::V1::Auth', type: :request do
  let(:origin) { Rails.application.config.x.authentication.allowed_origin }
  let(:password) { 'a-secure-password' }

  describe 'POST /api/v1/auth/register' do
    it 'creates an account and issues an access token and HttpOnly refresh cookie' do
      post '/api/v1/auth/register',
           params: { email: 'Ada@Example.com', password: password },
           as: :json

      expect(response).to have_http_status(:created)
      expect(response.parsed_body.dig('user', 'email')).to eq('ada@example.com')
      expect(response.parsed_body.dig('user', 'id')).to be_present
      expect(Authentication::AccessToken.authenticate(response.parsed_body['access_token'])).to eq(User.last)
      expect(response.parsed_body).not_to have_key('password')

      cookie = response.headers['Set-Cookie']
      expect(cookie.downcase).to include('httponly', 'samesite=lax', 'path=/api/v1/auth')
      expect(cookie.downcase).not_to include('domain=', 'secure')
      expect(RefreshSession.last.token_digest).not_to eq(response.cookies['refresh_token'])
    end

    it 'rejects duplicate email addresses regardless of case' do
      create(:user, email: 'ada@example.com')

      post '/api/v1/auth/register',
           params: { email: 'ADA@EXAMPLE.COM', password: password },
           as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(User.count).to eq(1)
    end

    it 'rejects passwords shorter than 12 characters' do
      post '/api/v1/auth/register',
           params: { email: 'ada@example.com', password: 'short-pass' },
           as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(User.count).to eq(0)
    end
  end
  describe 'POST /api/v1/auth/login' do
    let!(:user) { create(:user, email: 'ada@example.com', password: password) }

    it 'authenticates valid credentials' do
      post '/api/v1/auth/login',
           params: { email: user.email, password: password },
           as: :json

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.dig('user', 'id')).to eq(user.id)
      expect(response.parsed_body['access_token']).to be_present
      expect(response.cookies['refresh_token']).to be_present
    end

    it 'returns the same error for unknown email and incorrect password' do
      post '/api/v1/auth/login',
           params: { email: user.email, password: 'incorrect-password' },
           as: :json
      invalid_password_response = response.parsed_body

      post '/api/v1/auth/login',
           params: { email: 'unknown@example.com', password: 'incorrect-password' },
           as: :json

      expect(response).to have_http_status(:unauthorized)
      expect(response.parsed_body).to eq(invalid_password_response)
      expect(response.cookies['refresh_token']).to be_blank
    end
  end
  describe 'POST /api/v1/auth/refresh' do
    it 'rotates a valid refresh token and keeps the original expiration' do
      issued = Authentication::RefreshTokenService.issue(create(:user))
      cookies[:refresh_token] = issued.token

      post '/api/v1/auth/refresh', headers: { 'Origin' => origin }, as: :json

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body['access_token']).to be_present
      expect(response.cookies['refresh_token']).not_to eq(issued.token)
      expect(issued.session.reload.revoked_at).to be_present
      expect(RefreshSession.last.expires_at).to eq(issued.session.expires_at)
    end

    it 'rejects a cross-origin request without rotating the refresh session' do
      issued = Authentication::RefreshTokenService.issue(create(:user))
      cookies[:refresh_token] = issued.token

      post '/api/v1/auth/refresh', headers: { 'Origin' => 'https://attacker.example' }, as: :json

      expect(response).to have_http_status(:forbidden)
      expect(issued.session.reload.revoked_at).to be_nil
    end

    it 'rejects a request without an Origin header' do
      post '/api/v1/auth/refresh', as: :json

      expect(response).to have_http_status(:forbidden)
    end

    it 'clears the cookie when a refresh token is invalid' do
      cookies[:refresh_token] = 'invalid-token'

      post '/api/v1/auth/refresh', headers: { 'Origin' => origin }, as: :json

      expect(response).to have_http_status(:unauthorized)
      expect(response.headers['Set-Cookie'].downcase).to include('max-age=0')
    end
  end
  # rubocop:enable Metrics/BlockLength

  describe 'POST /api/v1/auth/logout' do
    it 'revokes the refresh-token family and clears the cookie' do
      issued = Authentication::RefreshTokenService.issue(create(:user))
      cookies[:refresh_token] = issued.token

      post '/api/v1/auth/logout', headers: { 'Origin' => origin }, as: :json

      expect(response).to have_http_status(:no_content)
      expect(issued.session.reload.revoked_at).to be_present
      expect(response.headers['Set-Cookie'].downcase).to include('max-age=0')
    end

    it 'rejects a cross-origin logout request' do
      issued = Authentication::RefreshTokenService.issue(create(:user))
      cookies[:refresh_token] = issued.token

      post '/api/v1/auth/logout', headers: { 'Origin' => 'https://attacker.example' }, as: :json

      expect(response).to have_http_status(:forbidden)
      expect(issued.session.reload.revoked_at).to be_nil
    end
  end
end
