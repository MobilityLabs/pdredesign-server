class InventoryAccessRequestNotificationWorker
  include ::Sidekiq::Worker

  def perform(access_request_id)
    request = InventoryAccessRequest.find(access_request_id)
    inventory = request.inventory
    inventory.facilitators.collect(&:user).each do |facilitator|
      InventoryAccessRequestMailer
        .request_access(request, facilitator.email)
        .deliver_now
    end
  end
end
