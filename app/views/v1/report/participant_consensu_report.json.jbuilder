json.consensu_id        @consensus.id
json.assessment_id      @assessment.id
json.participant_id     @participant.id

json.questions          @consensus.questions do |question|
  
  json.id           question.id
  json.order        question.order
  #TODO: replace the mock value for real one
  json.score_value  1
  json.headline     question.headline
  json.content      question.content

end