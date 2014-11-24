json.title  @container.title
json.viewed @viewed 
json.slides @container.slides do |slide|
  json.title   slide.title
  json.image   (slide.image && !slide.image.try(:empty?)) && slide.image.url
  json.content slide.content
  json.sidebar_content slide.sidebar_content
end
