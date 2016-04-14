class AddRoleToInventoryMember < ActiveRecord::Migration
  def change
    add_column :inventory_members, :role, :string 
  end
end
