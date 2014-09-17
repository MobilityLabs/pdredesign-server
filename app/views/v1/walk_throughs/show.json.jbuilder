json.title @container.title
json.slides @container.slides do |index, slide|
  json.image   slide.image && slide.image.url
  json.content slide.content
  json.sidebar_content slide.sidebar_content
end
