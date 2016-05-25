json.id data_entry.id
json.name data_entry.name
json.created_at data_entry.created_at
json.updated_at data_entry.updated_at
json.inventory_id data_entry.inventory_id
json.deleted_at data_entry.deleted_at if data_entry.deleted_at.present?
json.general_data_question do
  json.partial! 'v1/data_entries/general_data_questions/general_data_question', general_data_question: data_entry.general_data_question
end
json.data_entry_question do
  json.partial! 'v1/data_entries/data_entry_questions/data_entry_question', data_entry_question: data_entry.data_entry_question if data_entry.data_entry_question.present?
end
json.data_access_question do
  json.partial! 'v1/data_entries/data_access_questions/data_access_question', data_access_question: data_entry.data_access_question if data_entry.data_access_question.present?
end
