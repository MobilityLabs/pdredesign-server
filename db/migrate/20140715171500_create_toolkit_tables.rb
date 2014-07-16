class CreateToolkitTables < ActiveRecord::Migration
  def change
    create_table :tool_phases do |t|
      t.string  :title
      t.text    :description
      t.integer :display_order
    end
    create_table :tool_categories do |t|
      t.string     :title
      t.integer    :display_order
      t.belongs_to :tool_phase
    end
    create_table :tool_subcategories do |t|
      t.string     :title
      t.integer    :display_order
      t.belongs_to :tool_category
    end
    create_table :tools do |t|
      t.string     :title
      t.text       :description
      t.string     :url
      t.boolean    :is_default
      t.integer    :display_order
      t.belongs_to :tool_category
      t.belongs_to :tool_subcategory
      t.belongs_to :user
    end
  end
end
