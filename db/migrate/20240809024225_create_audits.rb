class CreateAudits < ActiveRecord::Migration[6.0]
  def change
    create_table :audits do |t|
      t.string :notification
      t.text :jsonb
      t.references :auditable, polymorphic: true, null: false

      t.timestamps
    end
  end
end
