class AddDeletedAtToProductEntries < ActiveRecord::Migration
  def change
    add_column :product_entries, :deleted_at, :datetime
    add_index :product_entries, :deleted_at

    add_column :general_inventory_questions, :deleted_at, :datetime
    add_index :general_inventory_questions, :deleted_at

    add_column :product_questions, :deleted_at, :datetime
    add_index :product_questions, :deleted_at

    add_column :usage_questions, :deleted_at, :datetime
    add_index :usage_questions, :deleted_at

    add_column :technical_questions, :deleted_at, :datetime
    add_index :technical_questions, :deleted_at
  end
end
