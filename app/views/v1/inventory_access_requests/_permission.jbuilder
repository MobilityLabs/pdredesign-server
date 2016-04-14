json.inventory_id access_request.inventory_id

json.partial! 'user_info', user: access_request.user, inventory: access_request.inventory

json.requested_permission_level access_request.role
