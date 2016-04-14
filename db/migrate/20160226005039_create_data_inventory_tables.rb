class CreateDataInventoryTables < ActiveRecord::Migration
  def change
    create_table :general_data_questions do |t|
      t.string :subcategory
      t.string :point_of_contact_name
      t.string :point_of_contact_department
      t.string :data_capture
      t.timestamps
    end

    create_table :data_entry_questions do |t|
      t.string :who_enters_data
      t.string :how_data_is_entered
      t.string :when_data_is_entered
      t.timestamps
    end

    create_table :data_access_questions do |t|
      t.string :data_storage
      t.string :who_access_data
      t.string :how_data_is_accessed
      t.string :why_data_is_accessed
      t.string :notes
      t.timestamps
    end
  end
end
