json.array! @candidates do |candidate|
  json.partial! 'v1/tool_members/_eligible_tool_members', candidate: candidate
end