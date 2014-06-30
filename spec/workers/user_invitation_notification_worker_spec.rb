require 'spec_helper'

describe UserInvitationNotificationWorker do
  let(:subject) { UserInvitationNotificationWorker }
  before do
    @invitation = UserInvitation
      .create!(email: 'some_user@email.com',
               assessment_id: 1)
  end

  it 'queues the twitter avatar updater job' do
    subject.perform_async(@invitation.id)
    expect(subject.jobs.count).to eq(1)
  end

  it 'finds the correct user' do
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

end
