json.name          subcategory.title
json.display_order subcategory.display_order

json.tools subcategory.tools do |tool|
  json.title         tool.title
  json.descripition  tool.description
  json.url           tool.url
  json.display_order tool.display_order
end
