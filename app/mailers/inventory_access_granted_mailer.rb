class InventoryAccessGrantedMailer < ApplicationMailer
  def notify(inventory, user, role)
    subject = "Your access was granted"
    @participant_name = user.name
    @inventory_name  = inventory.name
    @inventory_link  = inventories_url
    @participant_role = role
    mail(subject: subject, to: user.email)
  end
end
