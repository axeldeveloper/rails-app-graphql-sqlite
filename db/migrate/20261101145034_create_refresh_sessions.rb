# frozen_string_literal: true

# Stores hashed refresh credentials and their revocation state.
class CreateRefreshSessions < ActiveRecord::Migration[7.1]
  def change
    create_table :refresh_sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :token_digest, null: false
      t.string :family_id, null: false
      t.datetime :expires_at, null: false
      t.datetime :revoked_at

      t.timestamps
    end

    add_index :refresh_sessions, :token_digest, unique: true
    add_index :refresh_sessions, :family_id
  end
end
