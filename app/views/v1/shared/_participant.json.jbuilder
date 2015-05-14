participant_status = Assessments::ParticipantStatus.new(participant)
assessment_permission = Assessments::Permission.new(Assessment.find(params[:assessment_id]))

json.assessment_id participant.assessment_id
json.participant_id participant.id
json.status        participant_status.status 
json.status_human  participant_status.to_s
json.status_date   participant_status.date
json.permission_level assessment_permission.user_level(participant.user)

json.partial! 'v1/shared/user', user: participant.user

