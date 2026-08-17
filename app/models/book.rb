# frozen_string_literal: true

class Book < ApplicationRecord

  ALL_GENRES = %w[Thriller Horror Mystery Comedy Action Adventure Police Drama Suspension].freeze

  enum genre: ALL_GENRES.zip(ALL_GENRES).to_h

  validates :title, presence: true
  validates :publication_date, presence: true
  validates :genre, presence: true

  belongs_to :author, optional: true

  has_many :audits, as: :auditable

  default_scope { order(id: :desc) }

  scope :order_title, -> { order(:title) }

  scope :top, ->(limit) { limit(limit) }

  scope :recent_books, ->(since_when) { where('created_at >= ?', since_when) }

  def self.ordered
    order('publication_date')
  end

  def self.premium_user_ids
    Rails.cache.fetch 'app_premium_user_ids', expires_in: 1.minute do
      # microservice call
      # Simulação de uma consulta cara ao banco de dados
    end
  end
end
