class RenameInventoryParticipantToInventoryMember < ActiveRecord::Migration
  def change
    rename_table :inventory_participants, :inventory_members
  end
end
