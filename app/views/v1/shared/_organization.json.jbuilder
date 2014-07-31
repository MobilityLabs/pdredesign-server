json.id   organization.id
json.name organization.name
json.logo image_url(organization.logo || 'fallback/default_organization.png')

json.categories do
  json.partial! 'v1/shared/categories',
    categories: organization.categories
end