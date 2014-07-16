json.id            phase.id
json.title         phase.title
json.description   phase.description
json.display_order phase.display_order

json.categories phase.tool_categories do |category|
  json.partial! 'category', category: category
end
