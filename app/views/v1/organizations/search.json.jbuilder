json.results do
  json.partial! 'v1/shared/organizations',
    organizations: @results
end
