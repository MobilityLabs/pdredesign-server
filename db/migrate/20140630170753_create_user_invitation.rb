class CreateUserInvitation < ActiveRecord::Migration
  def change
    create_table :user_invitations do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :team_role
      t.integer :assessment_id
    end
  end
end
