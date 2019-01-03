class AnalysisInvitationMailer < ApplicationMailer
  def invite(user_invitation)
    invite = AnalysisInvitation.find(user_invitation.id)
    user = invite.user
    @analysis = invite.analysis

    @first_name = user.first_name
    @facilitator_name = @analysis.inventory.owner.first_name
    @analysis_name = @analysis.name
    @district_name = @analysis.inventory.district.name
    @deadline = @analysis.deadline.strftime("%B %d, %Y")
    @analysis_link = invite_url(invite.token)
    @message = @analysis.message.try(:html_safe)

    mail(to: invite.email)
  end

  def reminder(analysis, message, participant)
    @first_name = participant.user.first_name
    @analysis_name = analysis.name
    @deadline = analysis.deadline.strftime("%B %d, %Y")
    @analysis_link = "#{ENV['BASE_URL']}/#/inventories/#{analysis.inventory_id}/analyses/#{analysis.id}/responses"
    @message = message.try(:html_safe)

    mail(subject: 'Analysis Reminder',
          to: participant.user.email)
  end

  private
  def invite_url(token)
    "#{ENV['BASE_URL']}/#/invitations/#{token}"
  end
end
