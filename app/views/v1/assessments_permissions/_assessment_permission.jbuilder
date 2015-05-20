assessment_permission = Assessments::Permission.new(access_request.assessment)
user                  = access_request.user

json.assessment_id              access_request.assessment_id
json.name                       user.name
json.avatar                     avatar_image(user.avatar)
json.email                      user.email
json.current_permission_level   assessment_permission.get_level(user)

json.requested_permission_level do
  json.array! access_request.roles do |role|
    json.role role
  end 
end

json.partial! 'v1/shared/user', user: access_request.user