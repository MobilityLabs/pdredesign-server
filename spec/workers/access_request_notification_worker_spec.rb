require 'spec_helper'

describe AccessRequestNotificationWorker do
  let(:subject) { AccessRequestNotificationWorker }

  before { create_magic_assessments }
  let(:assessment) { @assessment_with_participants }

  before do
    user     = Application::create_sample_user
    @request = AccessRequest.create!(user: user,
      assessment: assessment,
      roles: [:facilitator])
  end

  it 'sends an email to each facilitator' do
    double = double("mailer")
    assessment.facilitators << @facilitator

    expect(AccessRequestMailer).to receive(:request_access)
      .with(@request, @facilitator.email)
      .and_return(double)

    expect(AccessRequestMailer).to receive(:request_access)
      .with(@request, @facilitator2.email)
      .and_return(double)

    expect(double).to receive(:deliver_now).twice
    subject.new.perform(@request.id)
  end

end
