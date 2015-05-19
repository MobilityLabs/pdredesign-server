json.array! @access_requested do |ac|
  json.assessment_id    ac.assessment_id


  json.roles do
    json.array! ac.roles do |role|
      json.role role
    end 
  end

  json.partial! 'v1/shared/user', user: ac.user
end