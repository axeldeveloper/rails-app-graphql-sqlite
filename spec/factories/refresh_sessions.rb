# frozen_string_literal: true

FactoryBot.define do
  factory :refresh_session do
    association :user
    sequence(:token_digest) { |n| "digest-#{n}" }
    family_id { SecureRandom.uuid }
    expires_at { 30.days.from_now }
  end
end
