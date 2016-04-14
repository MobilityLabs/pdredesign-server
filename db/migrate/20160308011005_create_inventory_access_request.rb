class CreateInventoryAccessRequest < ActiveRecord::Migration
  def change
    create_table :inventory_access_requests do |t|
      t.references :inventory, null: false, foreign_key: { on_delete: :cascade, on_update: :cascade }
      t.references :user, null: false, foreign_key: { on_delete: :cascade, on_update: :cascade }
      t.string :role, null: false
      t.string :token
      t.timestamps
    end
  end
end
