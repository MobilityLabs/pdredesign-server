permission = Inventories::Permission.new(inventory: inventory, user: user)

json.partial! 'v1/shared/user', user: user

json.current_permission_level do
  level = permission.role
  json.role level
  json.human "#{level}".humanize
end   

json.possible_permission_levels do
  json.array! permission.available_roles do |role|
    json.role    role
    json.human   role.to_s.humanize
  end
end
