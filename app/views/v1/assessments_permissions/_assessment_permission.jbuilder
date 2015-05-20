json.assessment_id    access_request.assessment_id

json.roles do
  json.array! access_request.roles do |role|
    json.role role
  end 
end

json.partial! 'v1/shared/user', user: access_request.user