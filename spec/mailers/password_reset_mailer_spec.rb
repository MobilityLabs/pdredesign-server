require 'spec_helper' 

describe PasswordResetMailer do
  context '#reset' do
    let(:user) {
      u = FactoryGirl.create(:user, :with_district)
      u.update(reset_password_token: 'expected_token')
      u
    }

    let(:mail) {
      PasswordResetMailer.reset(user)
    }

    it 'sends the invite mail to the user on invite' do
      expect(mail.to).to include(user.email)
    end

    it 'sends a link to the reset URL' do
      expect(mail.body).to match('/#/reset/expected_token')
    end
  end
end
