# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:user) { build(:user) }

  it 'normalizes email addresses' do
    user.email = '  Ada@Example.com '

    expect(user).to be_valid
    expect(user.email).to eq('ada@example.com')
  end

  it 'requires a unique email address regardless of case' do
    create(:user, email: 'ada@example.com')
    duplicate = build(:user, email: 'ADA@EXAMPLE.COM')

    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:email]).to include('has already been taken')
  end

  it 'requires a password of at least 12 characters' do
    user.password = 'short-pass'

    expect(user).not_to be_valid
    expect(user.errors[:password]).to include('is too short (minimum is 12 characters)')
  end

  it 'stores a password digest instead of the raw password' do
    user.password = 'a-secure-password'
    user.save!

    expect(user.password_digest).not_to eq('a-secure-password')
    expect(user.authenticate('a-secure-password')).to eq(user)
  end
end
