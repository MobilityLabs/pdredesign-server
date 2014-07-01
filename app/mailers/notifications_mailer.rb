class NotificationsMailer < ActionMailer::Base
  default from: 'support@pdredesign.org'
  default from_name: 'PD Redesign'

  def signup(user)

  end

  def invite(user_invitation)
    invite = find_invite(user_invitation)
    user   = invite.user

    @first_name          = user.first_name
    @assessment_name     = invite.assessment.name 
    @assessment_district = invite.assessment.district.name
    @owner_name          = invite.assessment.user.first_name
    @message             = invite.assessment.message
    @due_date            = invite.assessment.due_date
    @avatar              = user.avatar || default_avatar
    @invite_link         = invite_url(invite.token)
    mail(to: invite.email)
  end

  private
  def invite_url(token)
    "#{ENV['BASE_URL']}/#/invitation/#{token}"
  end

  def default_avatar
    ActionController::Base.helpers.asset_path('fallback/default.png')
  end

  def find_invite(invite_id)
    UserInvitation.find(invite_id)
  end

end
