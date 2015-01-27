require 'spec_helper'

describe ResponseCompletedNotificationWorker do
  before { create_magic_assessments }
  before { create_responses }

  let(:subject)    { ResponseCompletedNotificationWorker }
  let(:assessment) { @assessment_with_participants }

  it 'sends the email to each participants email address' do
    double   = double("mailer")
    response = Response.find_by(responder_id: @participant.id)

    expect(ResponsesMailer).to receive(:submitted)
      .with(response)
      .and_return(double)

    expect(double).to receive(:deliver_now)
    subject.new.perform(response.id)
  end

end
