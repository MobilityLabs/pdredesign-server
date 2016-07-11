json.id inventory.id
json.name inventory.name
json.owner_id inventory.owner_id
json.facilitator do
  json.partial! 'v1/shared/user', user: inventory.owner
end
json.is_facilitator_or_participant inventory.facilitator?(user: current_user) || inventory.participant?(user: current_user)
json.due_date inventory.deadline
json.district_id inventory.district_id
json.district_name inventory.district.name
json.created_at inventory.created_at
json.updated_at inventory.updated_at
json.status inventory.status
json.has_access inventory.member?(user: current_user) || inventory.owner == current_user if current_user
json.participant_count inventory.participants.count
json.message inventory.message || default_inventory_message if current_user
json.messages @messages, :id, :category, :teaser, :sent_at do |message|
  json.id       message.id
  json.category message.category
  json.teaser   sanitize(message.teaser, tags: [])
  json.sent_at  message.sent_at
end
json.share_token inventory.share_token
json.analysis_count inventory.analyses.count
json.analysis inventory.current_analysis
