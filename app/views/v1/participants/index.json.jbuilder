json.array! @participants do |participant|
  json.partial! 'v1/shared/participant', participant: participant
end