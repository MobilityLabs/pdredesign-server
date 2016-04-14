class InventoryInvitationNotificationWorker
  include ::Sidekiq::Worker

  def perform(invite_id)
    invite = InventoryInvitation.find(invite_id)
    InventoryInvitationMailer.invite(invite).deliver_now

    member = InventoryMember.where(user_id: invite.user_id, inventory_id: invite.inventory_id).first
    member.invited_at = Time.now
    member.save
  end
end
