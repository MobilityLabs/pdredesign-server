class ApplicationMailer < ActionMailer::Base
  default from: 'support@mail.pdredesign.org'
  default from_name: 'PD Redesign'
  layout 'application_mailer'

  protected
  def assessment_url(id)
    "#{ENV['BASE_URL']}/#/assessments/#{id}/responses"
  end

  def inventory_url(id)
    "#{ENV['BASE_URL']}/#/inventories/#{id}/responses"
  end

  def assessments_url
  	"#{ENV['BASE_URL']}/#/assessments"
  end

  def inventories_url
  	"#{ENV['BASE_URL']}/#/inventories"
  end
end
