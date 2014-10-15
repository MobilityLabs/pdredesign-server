require 'spec_helper' 

describe ResponsesMailer do
  before { create_magic_assessments }
  before { create_responses }

  context '#submitted' do

    let(:mail) do
      response = Response.find_by(responder_id: @participant.id)
      response.responder.assessment.user.update(email: 'some@user.com')
      ResponsesMailer.submitted(response)
    end

    it 'sends the invite mail to the user on invite' do
      expect(mail.to).to include('some@user.com')
    end

    it 'has the correct assessment link' do
      assessment_id = @assessment_with_participants.id
      expect(mail.body).to include("/\#/assessments/#{assessment_id}/dashboard")
    end

  end
end
