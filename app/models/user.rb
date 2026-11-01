# frozen_string_literal: true

# An account allowed to authenticate API write operations.
class User < ApplicationRecord
  has_secure_password

  has_many :refresh_sessions, dependent: :destroy

  before_validation :normalize_email

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :email, uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 12 }, if: -> { password.present? }

  private

  def normalize_email
    self.email = email.to_s.strip.downcase
  end
end
