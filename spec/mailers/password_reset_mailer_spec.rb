require 'spec_helper' 

describe PasswordResetMailer do
  context '#reset' do
    let(:user) {
      FactoryGirl.create(:user, :with_district)
    }

    let(:mail) {
      PasswordResetMailer.reset(user)
    }

    before(:each) do
      user.update(email: 'some@user.com')
      user.update(reset_password_token: 'expected_token')
    end

    it 'sends the invite mail to the user on invite' do
      expect(mail.to).to include('some@user.com')
    end

    it 'sends a link to the reset URL' do
      expect(mail.body).to match('/#/reset/expected_token')
    end
  end
end
