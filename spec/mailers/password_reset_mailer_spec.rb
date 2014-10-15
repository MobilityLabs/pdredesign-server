require 'spec_helper' 

describe PasswordResetMailer do
  context '#reset' do
    before do
      @user = Application::create_sample_user
      @user.update(reset_password_token: 'expected_token',
                   email: 'some@user.com')
    end

    let(:mail) { PasswordResetMailer.reset(@user) }

    it 'sends the invite mail to the user on invite' do
      expect(mail.to).to include('some@user.com')
    end

    it 'sends a link to the reset URL' do
      expect(mail.body).to match('/#/reset/expected_token')
    end
  end
end
