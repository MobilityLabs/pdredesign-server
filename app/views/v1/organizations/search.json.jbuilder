json.results do
  json.partial! 'v1/organizations/list',
    organizations: @results
end
