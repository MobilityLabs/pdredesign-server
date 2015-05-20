json.array! @access_requested do |ac|
  json.partial! 'assessment_permission', access_request: ac
end