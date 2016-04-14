class NullableAssociationsInventory < ActiveRecord::Migration
  def change
    change_column_null :inventories, :data_entry_id, true
    change_column_null :inventories, :product_entry_id, true
  end
end
