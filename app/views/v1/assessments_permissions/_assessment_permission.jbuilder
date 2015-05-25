json.assessment_id              access_request.assessment_id

json.partial! 'user_info', user: access_request.user, assessment: access_request.assessment

json.requested_permission_level do
  json.array! access_request.roles do |role|
    json.role role
  end 
end