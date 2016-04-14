json.array! @users do |user|
  json.partial! 'user_info', user: user , inventory: @inventory
end
