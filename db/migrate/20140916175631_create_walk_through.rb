class CreateWalkThrough < ActiveRecord::Migration
  def change

    create_table :walk_through_containers do |t|
      t.string :title
      t.timestamps
    end

    create_table :walk_through_slides do |t|
      t.string :title
      t.string :type
      t.text   :content
      t.text   :sidebar_content
      t.string :image
      t.belongs_to :container

      t.timestamps
    end

  end
end
