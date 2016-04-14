class ChangeInventoryModelStringFieldsToText < ActiveRecord::Migration
  def change
    change_column :data_access_questions, :data_storage, :text
    change_column :data_access_questions, :who_access_data, :text
    change_column :data_access_questions, :how_data_is_accessed, :text
    change_column :data_access_questions, :why_data_is_accessed, :text
    change_column :data_access_questions, :notes, :text

    change_column :data_entry_questions, :who_enters_data, :text
    change_column :data_entry_questions, :how_data_is_entered, :text
    change_column :data_entry_questions, :when_data_is_entered, :text

    change_column :general_data_questions, :subcategory, :text
    change_column :general_data_questions, :point_of_contact_name, :text
    change_column :general_data_questions, :point_of_contact_department, :text
    change_column :general_data_questions, :data_capture, :text

    change_column :inventories, :name, :text
  end
end
