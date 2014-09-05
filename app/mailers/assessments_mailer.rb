class AssessmentsMailer < ApplicationMailer


  def assigned(assessment, participant)
    @assessment_name      = assessment.name 
    @assessment_url       = assessment_url(assessment.id)
    @assessment_district  = assessment.district.name
    @assessment_due_day   = assessment.due_date.strftime("%A")
    @assessment_due_date  = assessment.due_date.strftime("%e")
    @assessment_due_month = assessment.due_date.strftime("%B")
    @owner_name           = assessment.user.name
    @owner_image          = assessment.user.avatar
    @participant_name     = participant.user.first_name
    @message              = assessment.message && assessment.message.html_safe

    mail(subject: 'Invitation to participate in the Readiness Assessment',
         to: participant.user.email)
 end

  def reminder(assessment, message, participant)
    @assessment_name      = assessment.name 
    @assessment_url       = assessment_url(assessment.id)
    @assessment_district  = assessment.district.name
    @assessment_due_day   = assessment.due_date.strftime("%A")
    @assessment_due_date  = assessment.due_date.strftime("%e")
    @assessment_due_month = assessment.due_date.strftime("%B")
    @owner_name           = assessment.user.name
    @owner_image          = assessment.user.avatar
    @participant_name     = participant.user.first_name
    @reminder_message     = message.html_safe

    mail(subject: 'Assessment Reminder',
         to: participant.user.email)
  end

  private
  def assessment_url(id)
    "#{ENV['BASE_URL']}/#/assessments"
  end
end
