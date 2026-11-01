# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength -- Keep refresh lifecycle scenarios together.
RSpec.describe Authentication::RefreshTokenService do
  let(:user) { create(:user) }

  it 'stores only a digest of a new refresh token and uses a 30-day lifetime' do
    issued = described_class.issue(user)
    second_token = described_class.issue(user)

    expect(issued.session.token_digest).not_to eq(issued.token)
    expect(issued.session.token_digest).to eq(Digest::SHA256.hexdigest(issued.token))
    expect(issued.session.expires_at).to be_within(1.second).of(30.days.from_now)
    expect(second_token.token).not_to eq(issued.token)
  end

  it 'rotates a token without extending its absolute expiration' do
    issued = described_class.issue(user)
    rotated = described_class.rotate(issued.token)

    expect(issued.session.reload.revoked_at).to be_present
    expect(rotated.session.family_id).to eq(issued.session.family_id)
    expect(rotated.session.expires_at).to eq(issued.session.expires_at)
    expect(rotated.session.token_digest).not_to eq(rotated.token)
  end

  it 'revokes the token family when an invalidated token is reused' do
    issued = described_class.issue(user)
    rotated = described_class.rotate(issued.token)

    expect { described_class.rotate(issued.token) }.to raise_error(described_class::ReusedToken)
    expect(rotated.session.reload.revoked_at).to be_present
  end

  it 'rejects expired tokens and revokes their session' do
    issued = described_class.issue(user, now: 31.days.ago)

    expect { described_class.rotate(issued.token) }.to raise_error(described_class::InvalidToken)
    expect(issued.session.reload.revoked_at).to be_present
  end

  it 'revokes a refresh-token family on logout' do
    issued = described_class.issue(user)
    rotated = described_class.rotate(issued.token)

    expect(described_class.revoke(rotated.token)).to be(true)
    expect(rotated.session.reload.revoked_at).to be_present
    expect(described_class.revoke('unknown-token')).to be(false)
  end
end
# rubocop:enable Metrics/BlockLength
