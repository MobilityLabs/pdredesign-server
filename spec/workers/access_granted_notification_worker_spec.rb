require 'spec_helper'

describe AccessGrantedNotificationWorker do
  before { create_magic_assessments }
  let(:subject)             { AccessGrantedNotificationWorker }
  let(:assessment)          { @assessment_with_participants }
  let(:user_without_access) { Application.create_user }

  it "Should send email notification on notify method" do 
  	double = double("mailer")

    expect(AccessGrantedMailer).to receive(:notify)
      .with(assessment, user_without_access)
      .and_return(double)

    expect(double).to receive(:deliver)
    subject.new.perform(assessment.id, user_without_access.id)
  end
end