# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Authentication::AccessToken do
  let(:user) { create(:user) }

  it 'issues and authenticates a signed access token' do
    token = described_class.issue(user)

    expect(described_class.authenticate(token)).to eq(user)
  end

  it 'rejects malformed, incorrectly signed, and expired tokens' do
    valid_payload = { sub: user.id.to_s, exp: 1.hour.from_now.to_i }
    wrong_signature = JWT.encode(valid_payload, 'wrong-signing-key', described_class::ALGORITHM)
    expired = described_class.issue(user, now: 16.minutes.ago)

    expect(described_class.authenticate('not-a-jwt')).to be_nil
    expect(described_class.authenticate(wrong_signature)).to be_nil
    expect(described_class.authenticate(expired)).to be_nil
  end
end
