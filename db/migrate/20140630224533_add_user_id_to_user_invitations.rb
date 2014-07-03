class AddUserIdToUserInvitations < ActiveRecord::Migration
  def change
    add_column :user_invitations, :user_id, :integer
  end
end
