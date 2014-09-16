class CreateWalkThroughHtmlSlides < ActiveRecord::Migration
  def change

    create_table :walk_through_containers do |t|
      t.string :title
      t.timestamps
    end

    create_table :walk_through_image_slides do |t|
      t.string :content
      t.text   :sidebar_content

      t.timestamps
    end

    create_table :walk_through_html_slides do |t|
      t.text   :content
      t.text   :sidebar_content

      t.timestamps
    end

    create_table :walk_through_slides, id: false do |t|
      t.belongs_to :walk_through_slide
      t.belongs_to :walk_through_containers
      t.timestamps
    end
  end
end
