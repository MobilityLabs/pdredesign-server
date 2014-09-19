class CreateWalkThroughViewed < ActiveRecord::Migration
  def change
    create_table :walk_through_views do |t|
      t.belongs_to :walk_through_container
      t.timestamps
    end
  end
end
