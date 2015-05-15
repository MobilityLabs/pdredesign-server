participant_status = Assessments::ParticipantStatus.new(participant)
if params[:assessment_id]
  # It will include permission level information
  assessment_permission = Assessments::Permission.new(Assessment.find(params[:assessment_id]))
end

json.assessment_id participant.assessment_id
json.participant_id participant.id
json.status        participant_status.status 
json.status_human  participant_status.to_s
json.status_date   participant_status.date
if params[:assessment_id]
  json.permission_level 			assessment_permission.user_level(participant.user)
  json.possible_permission_levels 	assessment_permission.possible_roles_permissions(participant.user)
end

json.partial! 'v1/shared/user', user: participant.user

