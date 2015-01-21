class ApplicationMailer < ActionMailer::Base
  default from: 'support@mail.pdredesign.org'
  default from_name: 'PD Redesign'
  layout 'application_mailer'

  protected
  def assessment_url(id)
    "#{ENV['BASE_URL']}/#/assessments/#{id}/responses"
  end
end
