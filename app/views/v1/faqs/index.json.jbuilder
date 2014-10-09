json.array! @questions do |question|
  json.id        question.id
  json.role      question.role
  json.content   question.content
  json.answer    question.answer
  json.category  do 
    json.id      question.category.id 
    json.heading question.category.heading
  end
end
