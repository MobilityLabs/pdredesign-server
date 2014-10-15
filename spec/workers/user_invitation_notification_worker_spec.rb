require 'spec_helper'

describe UserInvitationNotificationWorker do
  before { create_magic_assessments }

  let(:subject) { UserInvitationNotificationWorker }
  let(:assessment) { @assessment_with_participants }

  before do
    @invitation = UserInvitation.create!(
                    user_id: @participant.user.id,
                    email: @participant.user.email,
                    assessment_id: assessment.id)
  end

  it 'queues the a job' do
    subject.perform_async(@invitation.id)
    expect(subject.jobs.count).to eq(1)
  end

  it 'finds the correct UserInvitation record' do
    found_invite = subject.new.send(:find_invite, @invitation.id)
    expect(found_invite).to eq(@invitation)
  end

  it 'sends the email to the new users email address' do
    double = double("mailer")
    expect(NotificationsMailer).to receive(:invite)
      .with(@invitation)
      .and_return(double)

    expect(double).to receive(:deliver)

    subject.new.perform(@invitation.id)
  end

  it 'sets the participant :invited_at' do
    double = double("mailer").as_null_object

    allow(NotificationsMailer).to receive(:invite).and_return(double)
    @participant.update(invited_at: nil) 

    subject.new.perform(@invitation.id)

    @participant.reload
    expect(@participant.invited_at).not_to be_nil
  end
    


end
