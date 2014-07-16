class RemoveCategoryIdFromTools < ActiveRecord::Migration
  def change
      remove_column :tools, :tool_category_id
  end
end
