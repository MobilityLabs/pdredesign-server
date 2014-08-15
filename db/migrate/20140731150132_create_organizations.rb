class CreateOrganizations < ActiveRecord::Migration
  def change
    create_table :organizations do |t|
      t.string :name
      t.string :logo
    end
    create_join_table :categories, :organizations
    create_join_table :organizations, :users
  end
end
