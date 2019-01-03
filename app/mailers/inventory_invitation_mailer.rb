class InventoryInvitationMailer < ApplicationMailer
  def invite(user_invitation)
    invite = InventoryInvitation.find(user_invitation.id)
    user = invite.user
    inventory = invite.inventory

    @first_name = user.first_name
    @facilitator_name = inventory.owner.first_name
    @inventory_name = inventory.name
    @district_name = inventory.district.name
    @deadline = inventory.deadline.strftime("%B %d, %Y")
    @inventory_link = invite_url(invite.token)
    @message = inventory.message.try(:html_safe)

    mail(to: invite.email)
  end

  def reminder(inventory, message, participant)
    @first_name = participant.user.first_name
    @facilitator_name = inventory.owner.first_name
    @inventory_name = inventory.name
    @district_name = inventory.district.name
    @deadline = inventory.deadline.strftime("%B %d, %Y")
    # @inventory_link = invite_url(invite.token)
    @message = message.try(:html_safe)

    mail(subject: 'Inventory Reminder',
          to: participant.user.email)
  end

  private
  def invite_url(token)
    "#{ENV['BASE_URL']}/#/invitations/#{token}"
  end
end
