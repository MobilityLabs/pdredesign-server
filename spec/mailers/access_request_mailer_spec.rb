require 'spec_helper'

describe AccessRequestMailer do
  before { create_magic_assessments }
  let(:assessment) { @assessment_with_participants }
  let(:subject)    { AccessRequestMailer }


  describe '#request_access' do

    it 'sends the email to the correct email' do
    invite = AccessRequest.create!(assessment_id: assessment.id,
                                    user: @user,
                                    roles: [:facilitator])

      mail = subject.request_access(invite, 'test@example.com')
      expect(mail.to).to include('test@example.com')
    end

  end
end
