# frozen_string_literal: true

class Audit < ApplicationRecord
  belongs_to :auditable, polymorphic: true

  # Adiciona dados ao JSON
  def self.create_audit_for(auditable, notification)
    create(
      auditable: auditable,
      notification: notification,
      jsonb: auditable.attributes.except('id', 'created_at', 'updated_at') # Ajuste os campos conforme necessário
    )
  end
end
