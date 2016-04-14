class AddOwnerToInventory < ActiveRecord::Migration
  def change
    add_reference :inventories, :owner
  end
end
