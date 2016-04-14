class AddTimestampToInventory < ActiveRecord::Migration
  def change
    change_table :inventories do |t|
      t.timestamps null: false
    end
  end
end
