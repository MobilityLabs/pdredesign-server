require 'spec_helper'

describe ReminderNotificationWorker do
  before { create_magic_assessments }
  let(:subject)    { ReminderNotificationWorker }
  let(:assessment) { @assessment_with_participants }

  it 'sends the email to each participants email address' do
    double = double("mailer")

    expect(AssessmentsMailer).to receive(:reminder)
      .exactly(2).times
      .with(assessment, 'the message', anything)
      .and_return(double)

    expect(double).to receive(:deliver_now).twice
    subject.new.perform(assessment.id, 'the message')
  end

  it 'does not send an email to users that have completed a response' do
    create_struct
    create_responses

    @participant.response.update(submitted_at: Time.now)
    @participant2.response.update(submitted_at: nil)

    double = double("mailer").as_null_object
    expect(AssessmentsMailer).to receive(:reminder)
      .exactly(1).times
      .with(anything, anything, @participant2).and_return(double)

    subject.new.perform(assessment.id, 'the message')

  end

  it 'sets the :reminded_at field' do
    subject.new.perform(assessment.id, 'the message')
    @participant.update(reminded_at: nil)
    @participant2.update(reminded_at: nil)

    @participant.reload
    @participant2.reload

    expect(@participant.reminded_at).not_to be_nil
    expect(@participant2.reminded_at).not_to be_nil
  end

  it 'adds a message entry for the assessment' do
    subject.new.perform(assessment.id, 'the message')
    message = Message
      .find_by(assessment_id: assessment.id,
               content: 'the message')

    expect(message).not_to be_nil
  end


end
