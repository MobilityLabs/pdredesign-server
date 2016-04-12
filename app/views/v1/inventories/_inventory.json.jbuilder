json.id inventory.id
json.name inventory.name
json.owner_id inventory.owner_id
json.facilitator do
  json.partial! 'v1/shared/user', user: inventory.owner
end
json.due_date inventory.deadline
json.district_id inventory.district_id
json.district_name inventory.district.name
json.created_at inventory.created_at
json.updated_at inventory.updated_at
json.status 'draft'
json.has_access inventory.member?(user: current_user) || inventory.owner == current_user
json.participant_count inventory.members.count
json.message inventory.message || default_inventory_message
json.messages inventory.messages, :id, :category, :teaser, :sent_at do |message|
  json.id       message.id
  json.category message.category
  json.teaser   sanitize(message.teaser, tags: [])
  json.sent_at  message.sent_at
end
