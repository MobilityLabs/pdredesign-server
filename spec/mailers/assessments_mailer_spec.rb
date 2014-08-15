require 'spec_helper'

describe AssessmentsMailer do
  before { create_magic_assessments }
  let(:assessment) { @assessment_with_participants }
  let(:subject)    { AssessmentsMailer }


  describe '#assigned' do
    it 'sends the email to the correct email' do
      mail = subject.assigned(assessment, @participant)
      expect(mail.to).to include(@participant.user.email)
    end
  end

  describe '#reminder' do
    it 'sends the meail to the correct participant' do  
      mail = subject.reminder(assessment, 'reminder', @participant)
      expect(mail.to).to include(@participant.user.email)
    end
  end
end
