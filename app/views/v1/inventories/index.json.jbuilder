json.inventories @inventories do |inventory|
  json.partial! 'v1/inventories/inventory', inventory: inventory
end
