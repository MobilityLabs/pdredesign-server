json.results do
  json.partial! 'v1/shared/categories',
    categories: @categories
end