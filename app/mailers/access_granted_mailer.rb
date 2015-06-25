class AccessGrantedMailer < ApplicationMailer
  
  def notify(assessment, user, role)
    subject = "Your access was granted"
    @participant_name = user.name
    @assessment_name  = assessment.name
    @assessment_link  = assessments_url
    @participant_role = role

    mail(subject: subject, to: user.email)
  end
end