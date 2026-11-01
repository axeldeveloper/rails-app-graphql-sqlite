# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RefreshSession, type: :model do
  it 'belongs to a user and requires refresh-session data' do
    session = build(:refresh_session, user: nil, token_digest: nil, family_id: nil, expires_at: nil)

    expect(session).not_to be_valid
    expect(session.errors).to include(:user, :token_digest, :family_id, :expires_at)
  end

  it 'is active only while unrevoked and unexpired' do
    active_session = create(:refresh_session)
    revoked_session = create(:refresh_session, revoked_at: Time.current)
    expired_session = create(:refresh_session, expires_at: 1.minute.ago)

    expect(active_session).to be_active
    expect(revoked_session).not_to be_active
    expect(expired_session).not_to be_active
  end
end
