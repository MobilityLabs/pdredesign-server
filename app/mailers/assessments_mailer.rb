class AssessmentsMailer < ApplicationMailer


  def assigned(assessment, participant)
    @first_name = participant.user.first_name
    @facilitator_name = assessment.user.name
    @assessment_name  = assessment.name 
    @assessment_link  = assessment_url(assessment.id)
    @district_name    = assessment.district.name
    @due_date         = assessment.due_date.strftime("%B %d, %Y")
    @message          = assessment.message && assessment.message.html_safe

    subject = 'Invitation to participate in the Readiness Assessment'
    mail(subject: subject, to: participant.user.email) do |format|
      format.html { render 'notifications_mailer/invite' }
      format.text { render 'notifications_mailer/invite' }
    end
 end

  def reminder(assessment, message, participant)
    @participant_name = participant.user.first_name
    @facilitator_name = assessment.user.name
    @assessment_name  = assessment.name 
    @assessment_link  = assessment_url(assessment.id)
    @district_name    = assessment.district.name
    @due_date         = assessment.due_date.strftime("%B %d, %Y")
    @message          = message.html_safe

    mail(subject: 'Assessment Reminder',
         to: participant.user.email)
  end

end
