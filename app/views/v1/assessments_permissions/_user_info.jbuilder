assessment_permission = Assessments::Permission.new(assessment)

json.partial! 'v1/shared/user', user: user

json.current_permission_level do
  level = assessment_permission.get_level(user)

  json.role    level
  json.human   level.nil? ? '' : level.to_s.humanize
end   

json.possible_permission_levels do
  json.array! assessment_permission.possible_roles_permissions(user) do |role|
    json.role    role
    json.human   role.to_s.humanize
  end
end