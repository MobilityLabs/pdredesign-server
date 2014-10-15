class ApplicationMailer < ActionMailer::Base
  default from: 'support@pdredesign.org'
  default from_name: 'PD Redesign'
  layout 'application_mailer'
end
