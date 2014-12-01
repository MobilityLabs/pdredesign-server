class CreateWalkThroughViewed < ActiveRecord::Migration
  def change
    create_table :walk_through_views do |t|
      t.belongs_to :container
      t.belongs_to :user
      t.timestamps
    end
  end
end
