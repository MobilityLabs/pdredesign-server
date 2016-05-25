class AddDeletedAtToDataEntries < ActiveRecord::Migration
  def change
    add_column :data_entries, :deleted_at, :datetime
    add_index :data_entries, :deleted_at

    add_column :general_data_questions, :deleted_at, :datetime
    add_index :general_data_questions, :deleted_at

    add_column :data_entry_questions, :deleted_at, :datetime
    add_index :data_entry_questions, :deleted_at

    add_column :data_access_questions, :deleted_at, :datetime
    add_index :data_access_questions, :deleted_at
  end
end
