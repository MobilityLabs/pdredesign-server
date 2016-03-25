json.id @response.id
json.submitted_at @response.submitted_at
json.is_completed !@response.submitted_at.blank?

json.partial! 'v1/consensus/consensus_slimmed' if @response.is_consensus?

number = 0
json.categories @categories do |category|
  json.id category.id
  json.name category.name
  json.axis_id category.axis_id

  json.questions category.rubric_questions(@rubric) do |question|
    json.number number += 1
    json.id question.id
    json.order question.order
    json.content question.content
    json.headline question.headline
    json.category_id question.category_id
    json.score controller.score_for(@response, question)
    json.answers question.ordered_answers
    json.partial! 'v1/consensus/question', question: question if @response.is_consensus?
    json.partial! 'v1/shared/key_question', key_question: question.key_question if question.key_question
  end
end

