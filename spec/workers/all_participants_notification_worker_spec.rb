require 'spec_helper'

describe AllParticipantsNotificationWorker do
  let(:subject) { AllParticipantsNotificationWorker }

  before { create_magic_assessments }

  let(:assessment) { @assessment_with_participants }

  it 'sends an email to each participant' do
    double = double("mailer")

    expect(AssessmentsMailer).to receive(:assigned)
      .with(anything, @participant)
      .and_return(double)

    expect(AssessmentsMailer).to receive(:assigned)
      .with(anything, @participant2)
      .and_return(double)

    expect(double).to receive(:deliver).twice
    subject.new.perform(assessment.id)
  end

  it 'updates the invited_at timestamp for each participant' do
    double = double("mailer").as_null_object
    allow(AssessmentsMailer).to receive(:assigned).and_return(double)
    
    @participant.update(invited_at: nil)
    @participant2.update(invited_at: nil)

    subject.new.perform(assessment.id)

    @participant.reload
    @participant2.reload

    expect(@participant.invited_at).not_to be_nil
    expect(@participant2.invited_at).not_to be_nil
  end

  it 'does not deliver to already invited users' do
    double = double("mailer").as_null_object

    @participant.update(invited_at: Time.now)

    expect(AssessmentsMailer).to receive(:assigned)
      .with(anything, @participant2)
      .and_return(double)

    subject.new.perform(assessment.id)
  end

  context 'with invite' do
    before do
      @invite = UserInvitation.create!(
                  first_name: 'test',
                  last_name:  'test',
                  email: @participant.user.email,
                  team_role:  'worker',
                  token:      'token',
                  user: @participant.user,
                  assessment_id: assessment.id)

    end

    it 'sends an invitation email to invited participants' do
      double = double("mailer").as_null_object


      expect(NotificationsMailer).to receive(:invite)
        .with(@invite)
        .and_return(double)

      expect(AssessmentsMailer).to receive(:assigned)
        .with(anything, @participant2)
        .and_return(double)

      subject.new.perform(assessment.id)
    end
  end

end
