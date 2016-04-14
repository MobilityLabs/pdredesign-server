json.id inventory.id
json.name inventory.name
json.owner_id inventory.owner_id
json.facilitator do
  json.partial! 'v1/shared/user', user: inventory.owner
end
json.deadline inventory.deadline
json.district_id inventory.district_id
json.district_name inventory.district.name
json.created_at inventory.created_at
json.updated_at inventory.updated_at
json.status 'draft'
json.has_access inventory.member?(user: current_user) || inventory.owner == current_user