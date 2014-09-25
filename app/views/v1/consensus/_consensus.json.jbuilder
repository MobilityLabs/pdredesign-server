json.participant_count   @response.responder.participants.count
json.team_roles          @team_roles
json.scores scores_for_assessment(@response.responder, @team_role) do |score|
  json.id          score.id
  json.value       score.value
  json.evidence    score.evidence
  json.response_id score.response_id
  json.question_id score.question_id
  json.created_at  score.created_at

  json.participant do
    json.partial! 'v1/shared/participant', participant: score.response.responder
  end
end
