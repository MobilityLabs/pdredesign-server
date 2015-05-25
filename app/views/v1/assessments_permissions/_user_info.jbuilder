assessment_permission = Assessments::Permission.new(assessment)

json.partial! 'v1/shared/user', user: user

json.current_permission_level   assessment_permission.get_level(user)
json.possible_permission_levels assessment_permission.possible_roles_permissions(user)