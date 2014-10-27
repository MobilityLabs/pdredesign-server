json.array! @categories do |category|
  json.id      category.id 
  json.heading category.heading

  json.questions category.questions do |question|
    json.id        question.id
    json.role      question.role
    json.topic     question.topic
    json.content   question.content
    json.answer    question.answer
  end
end

