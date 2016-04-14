class CreateInventoryParticipants < ActiveRecord::Migration
  def change
    create_table :inventory_participants do |t|
      t.references :inventory, null: false, index: true, foreign_key: { on_delete: :cascade, on_update: :cascade }
      t.references :user, null: false, index: true, foreign_key: { on_delete: :cascade, on_update: :cascade }
      t.timestamps
      t.datetime :invited_at
    end
  end
end
