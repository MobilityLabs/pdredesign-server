class NotificationsMailer < ActionMailer::Base
  default from: 'support@pdredesign.org'
  default from_name: 'PD Redesign'

  def signup(user)

  end

  def invite(user_invitation)
    invite = find_invite(user_invitation)
    mail(to: invite.email)
  end

  private
  def find_invite(invite_id)
    UserInvitation.find(invite_id)
  end

end
