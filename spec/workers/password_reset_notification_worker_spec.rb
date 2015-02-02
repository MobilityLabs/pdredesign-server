require 'spec_helper'

describe PasswordResetNotificationWorker do
  let(:subject) { PasswordResetNotificationWorker }
  before do
    @user = Application::create_sample_user
  end

  it 'sends the email to each participants email address' do
    double = double("mailer")

    expect(PasswordResetMailer).to receive(:reset)
      .with(@user)
      .and_return(double)

    expect(double).to receive(:deliver_now)
    subject.new.perform(@user.id)
  end

end
