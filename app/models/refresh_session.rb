# frozen_string_literal: true

# A single revocable refresh credential in an account's token family.
class RefreshSession < ApplicationRecord
  belongs_to :user

  validates :token_digest, :family_id, :expires_at, presence: true

  scope :active, -> { where(revoked_at: nil).where('expires_at > ?', Time.current) }

  def active?
    revoked_at.nil? && expires_at.future?
  end
end
