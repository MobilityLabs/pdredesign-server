class InventoryAccessGrantedNotificationWorker
  include ::Sidekiq::Worker

  def perform(inventory_id, user_id, role)
    inventory = Inventory.find(inventory_id)
    user = User.find(user_id)
    InventoryAccessGrantedMailer.notify(inventory, user, role).deliver_now
  end
end
