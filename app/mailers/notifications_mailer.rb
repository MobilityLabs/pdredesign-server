class NotificationsMailer < ApplicationMailer

  def signup(user)

  end

  def invite(user_invitation)
    invite = find_invite(user_invitation)
    user   = invite.user

    @first_name          = user.first_name
    @facilitator_name    = invite.assessment.user.first_name
    @assessment_name     = invite.assessment.name 
    @district_name       = invite.assessment.district.name
    @message             = invite.assessment.message.html_safe
    @due_date            = invite.assessment.due_date.strftime("%B %d, %Y")    
    @assessment_link     = invite_url(invite.token)

    mail(to: invite.email)
  end

  private
  def invite_url(token)
    "#{ENV['BASE_URL']}/#/invitations/#{token}"
  end

  def default_avatar
    ActionController::Base.helpers.asset_path('fallback/default.png')
  end

  def find_invite(invite_id)
    UserInvitation.find(invite_id)
  end

end
