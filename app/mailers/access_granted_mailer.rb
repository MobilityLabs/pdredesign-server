class AccessGrantedMailer < ApplicationMailer
  
  def notify(assessment, user)
    subject = "Your access was granted"
    @participant_name = user.name
    @assessment_name  = assessment.name
    @assessment_link  = assessment_url(assessment.id)

    mail(subject: subject, to: user.email)
  end
end