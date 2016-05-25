json.id product_entry.id
json.created_at product_entry.created_at
json.updated_at product_entry.updated_at
json.inventory_id product_entry.inventory_id
json.deleted_at product_entry.deleted_at if product_entry.deleted_at.present?
json.general_inventory_question do
  json.partial! 'v1/product_entries/general_inventory_questions/general_inventory_question', general_inventory_question: product_entry.general_inventory_question
end
json.product_question do
  json.partial! 'v1/product_entries/product_questions/product_question', product_question: product_entry.product_question if product_entry.product_question.present?
end
json.usage_question do
  json.partial! 'v1/product_entries/usage_questions/usage_question', usage_question: product_entry.usage_question
end
json.technical_question do
  json.partial! 'v1/product_entries/technical_questions/technical_question', technical_question: product_entry.technical_question
end
