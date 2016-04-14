json.array! @users do |user|
  json.partial! 'v1/shared/user', user: user
end

