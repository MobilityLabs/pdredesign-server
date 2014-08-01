json.id               user.id
json.email            user.email
json.first_name       user.first_name
json.last_name        user.last_name
json.full_name        user.name
json.twitter          user.twitter
json.created_at       user.created_at
json.updated_at       user.updated_at
json.role             user.role
json.role_human       (user.role && user.role.to_s.humanize)
json.team_role        user.team_role
json.avatar           image_url(user.avatar || 'fallback/default.png')
json.district_ids     user.district_ids
json.organization_id  user.organization_ids.first

json.districts do
  json.partial! 'v1/shared/districts',
    districts: fetch_districts(user.district_ids)
end