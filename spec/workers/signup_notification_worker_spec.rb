require 'spec_helper'

describe SignupNotificationWorker do
  let(:subject) { SignupNotificationWorker }
  before do
    @user = Application::create_sample_user
  end

  it 'queues the twitter avatar updater job' do
    subject.perform_async(@user.id)
    expect(subject.jobs.count).to eq(1)
  end

  it 'finds the correct user' do
    found_user = subject.new.send(:find_user, @user.id)
    expect(found_user).to eq(@user)
  end

  it 'sends the email to the new users email address' do
    double = double("mailer")
    expect(NotificationsMailer).to receive(:signup)
      .with(@user)
      .and_return(double)

    expect(double).to receive(:deliver_now)

    subject.new.perform(@user.id)
  end

end
