class InventoryInvitationMailer < ApplicationMailer
  def invite(user_invitation)
    invite = InventoryInvitation.find(user_invitation)
    user   = invite.user
    inventory = invite.inventory

    @first_name          = user.first_name
    @facilitator_name    = inventory.owner.first_name
    @inventory_name     = inventory.name 
    @district_name       = inventory.district.name
    @due_date            = inventory.deadline.strftime("%B %d, %Y")    
    @inventory_link     = invite_url(invite.token)
    
    mail(to: invite.email)
  end

  private
  def invite_url(token)
    "#{ENV['BASE_URL']}/#/inventories/invitations/#{token}"
  end

  def default_avatar
    ActionController::Base.helpers.asset_path('fallback/default.png')
  end
end
