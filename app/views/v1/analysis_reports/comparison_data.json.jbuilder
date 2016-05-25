json.array! @comparison_data do |comparison_data|
  json.id comparison_data.id
  json.product_name comparison_data.product_name
  json.price_in_cents comparison_data.price_in_cents
  json.usage comparison_data.usage
end
