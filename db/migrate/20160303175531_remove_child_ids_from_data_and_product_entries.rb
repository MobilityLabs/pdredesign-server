class RemoveChildIdsFromDataAndProductEntries < ActiveRecord::Migration
  def change
    remove_column :product_entries, :general_inventory_question_id, :integer
    remove_column :product_entries, :product_question_id, :integer
    remove_column :product_entries, :usage_question_id, :integer
    remove_column :product_entries, :technical_question_id, :integer

    remove_column :data_entries, :general_data_question_id, :integer
    remove_column :data_entries, :data_entry_question_id, :integer
    remove_column :data_entries, :data_access_question_id, :integer
  end
end
