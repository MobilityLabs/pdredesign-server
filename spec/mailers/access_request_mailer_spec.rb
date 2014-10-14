require 'spec_helper'

describe AccessRequestMailer do
  before { create_magic_assessments }
  let(:assessment) { @assessment_with_participants }
  let(:subject)    { AccessRequestMailer }


  describe '#request_access' do
    before do
      @invite = AccessRequest.create!(
                assessment_id: assessment.id,
                token: 'expected',
                user: @user,
                roles: [:facilitator])

    end

    it 'sends the email to the correct email' do
      mail = subject.request_access(@invite, 'test@example.com')
      expect(mail.to).to include('test@example.com')
    end

    it 'containers the correct link' do
      mail = subject.request_access(@invite, 'test@example.com')
      expect(mail.body).to include('/#/grant/expected')
    end

  end
end
