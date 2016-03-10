class RemoveDataAndProductColumnsFromInventory < ActiveRecord::Migration
  def change
    remove_column :inventories, :data_entry_id, :integer
    remove_column :inventories, :product_entry_id, :integer
  end
end
