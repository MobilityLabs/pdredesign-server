json.id            subcategory.id
json.name          subcategory.title
json.display_order subcategory.display_order

json.tools controller.tools_for(subcategory) do |tool|
  json.title         tool.title
  json.description   tool.description
  json.url           tool.url
  json.display_order tool.display_order
end
