# == Schema Information
#
# Table name: assessments
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  due_date        :datetime
#  meeting_date    :datetime
#  user_id         :integer
#  rubric_id       :integer
#  created_at      :datetime
#  updated_at      :datetime
#  district_id     :integer
#  message         :text
#  assigned_at     :datetime
#  mandrill_id     :string(255)
#  mandrill_html   :text
#  report_takeaway :text
#

require 'spec_helper'

describe Assessment do
  describe 'validations' do
    it { should validate_presence_of :name }
    it { should validate_presence_of :rubric_id }
    it { should validate_presence_of :district_id }

    context ':assigned_at' do
      before do
        @assessment = Assessment.new(assigned_at: Time.now)
      end

      it 'requires :due_date when assigned_at is present' do
        expect(@assessment.valid?).to eq(false) 
        expect(@assessment.errors[:due_date])
          .to include("can\'t be blank")

        @assessment.assigned_at = nil
        @assessment.valid?
        expect(@assessment.errors[:due_date])
          .to eq([])
      end

      it 'requires :due_date when assigned_at is present' do
        expect(@assessment.valid?).to eq(false) 
        expect(@assessment.errors[:message])
          .to include("can\'t be blank")

        @assessment.assigned_at = nil
        @assessment.valid?
        expect(@assessment.errors[:message])
          .to eq([])
      end

      context '#assignable?' do
        it 'requires participants when assigned' do
          participant = Participant.new(user_id: 1)

          expect(@assessment.valid?).to eq(false) 
          expect(@assessment.errors[:participant_ids])
            .to include("You must assign participants to this assessment.")

          @assessment.participants = [participant]
          @assessment.valid?
          expect(@assessment.errors[:participant_ids])
            .to eq([])

        end
      end
    end
  end

  describe '#pending_requests?' do
    before { create_magic_assessments }
    let(:assessment) { @assessment_with_participants }

    it 'returns true when there are pending requests for a user' do
      expect(assessment.pending_requests?(@user3)).to eq(false)

      AccessRequest.create!(user_id: @user3.id, assessment_id: assessment.id,
                            roles: [:viewer])
      expect(assessment.pending_requests?(@user3)).to eq(true)
    end
  end

  describe '#completed?' do
    before { @assessment = Assessment.new }
    it 'is completed' do
      allow(@assessment).to receive(:percent_completed)
        .and_return(100)
      expect(@assessment.completed?).to eq(true)
    end

    it 'is not completed' do 
      allow(@assessment).to receive(:percent_completed)
        .and_return(99)
      expect(@assessment.completed?).to eq(false)
    end
  end

  describe 'status' do
    before { @assessment = Assessment.new }

    it 'is draft when not assigned' do
      allow(@assessment).to receive(:assigned_at).and_return(nil) 
      expect(@assessment.status).to eq(:draft)
    end

    it 'is consensus when response is present' do
      allow(@assessment).to receive(:assigned_at)
        .and_return(true) 

      allow(@assessment).to receive(:response)
        .and_return(true) 

      expect(@assessment.status).to eq(:consensus)
    end

    it 'is assessment when response is not present' do
      allow(@assessment).to receive(:assigned_at)
        .and_return(true) 

      allow(@assessment).to receive(:response)
        .and_return(false) 

      expect(@assessment.status).to eq(:assessment)
    end
  end
  
  describe '#answered_scores' do
    let(:assessment) { @assessment_with_participants }

    before { create_magic_assessments }
    before do
      create_struct
      Response
        .find(99)
        .update(responder: @participant, submitted_at: Time.now)
    end

    it 'returns all the scores for an assessment' do
      expect(assessment.answered_scores.count).to eq(3)
    end

    it 'does not count Assessment scores' do
      Response.create(responder_id:   assessment.id,
                      responder_type: 'Assessment',
                      submitted_at: Time.now,
                      id: 42)

      expect(assessment.answered_scores.count).to eq(3)
    end

    it 'does not return nil scores' do
      Score.first.update(value: nil)
      expect(assessment.answered_scores.count).to eq(2)
    end

    describe '#scores_for_team_role' do
      let(:assessment) { @assessment_with_participants }
      before { create_magic_assessments }

      before do
       create_struct

       Response
         .find(99)
         .update(responder: @participant, submitted_at: Time.now)
      end     

      it 'returns scores for the specified :team_role' do
        expect(assessment.scores_for_team_role(:worker).count).to eq(0)

        @user.update(team_role: :worker)

        expect(assessment.scores_for_team_role(:worker).count).to eq(3)
      end

      it 'does not return nil scores' do
        assessment.answered_scores.first.update(value: nil)

        @user.update(team_role: :worker)
        expect(assessment.scores_for_team_role(:worker).count).to eq(2)
      end
    end


    describe '#scores' do
      it 'returns scores for a particular question id' do
        question = Question.find_by(headline: "headline 1")
        expect(assessment.scores(question.id).count).to eq(1)
      end
    end
  end

  describe '#score_count' do
    before { create_magic_assessments }
    before { create_struct }
    before { create_responses }

    let(:assessment) { @assessment_with_participants }

    it 'returns the number of scores for a question + response' do
      question = Question.find_by(headline: "question1")
      expect(assessment.score_count(question, 1)).to eq(1)
    end
  end

  describe 'with data' do
    before { create_magic_assessments }
    let(:assessment) { @assessment_with_participants }

    context '#assessments_for_user' do
      it 'returns all assessments for district_members' do
        records = Assessment.assessments_for_user(@facilitator)
        expect(records.count).to eq(3)

        @facilitator.update(role: :member)
        records = Assessment.assessments_for_user(@facilitator)
        expect(records.count).to eq(3)
      end

      it 'returns all assessments in every district for network_partners' do
        @user.update(role: :network_partner)
        @user.update(district_ids: [@district.id])

        records = Assessment.assessments_for_user(@user)
        expect(records.count).to eq(3)

        @user.update(district_ids: [@district.id, @district2.id])
        records = Assessment.assessments_for_user(@user)
        expect(records.count).to eq(4)
      end
    end

    context '#participant?' do
      it 'returns true when a user is a participant of an assessment' do
        expect(assessment.participant?(@user)).to eq(true)
      end

      it 'returns true when a user is a participant of an assessment' do
        assessment.participants.find_by(user_id: @user.id).destroy
        expect(assessment.participant?(@user)).to eq(false)
      end
    end

    context 'with consensus' do
      before do 
        @consensus = Response
          .create(responder_type: 'Assessment', 
                  responder: @assessment_with_participants)

      end

      context '#consensus' do
        it 'returns the consensus' do
          consensus = assessment.consensus
          expect(consensus.id).to eq(@consensus.id)
        end

        it 'returns nil whne consensus is not present' do
          @consensus.destroy
          consensus = assessment.consensus
          expect(consensus).to eq(nil)
        end
      end
    end

    context 'with response' do
      before do 
        @response = Response
          .create(responder_type: 'Participant', 
        responder: @participant)
      end

      def response_count(method)
        assessment.send(method).count
      end

      context '#responses' do
        it 'returns the users response' do
          responses = assessment.responses(@user)
          expect(responses.count).to eq(1)
          expect(responses.first.id).to eq(@response.id)
        end
      end

      describe '#participant_response' do
        it 'returns the participants submitted responses' do
          expect do
            @response.update(submitted_at: Time.now)
          end.to change{ response_count(:participant_responses) }.by(1)
       end
      end

      describe '#participants_not_responded' do
        it 'returns the participants that have not responded' do
          expect do
            @response.update(submitted_at: Time.now)
          end.to change{ response_count(:participants_not_responded) }.by(-1)
       end
      end

      describe '#participants_viewed_report' do
        it 'gets users who have viewed the report' do
          expect do
            @participant.update(report_viewed_at: Time.now)
          end.to change{ response_count(:participants_viewed_report) }.by(1)
        end
      end

      describe '#response_submitted' do
        before do
          @response = Response.create(responder_type: 'Assessment',
                                      responder:      @facilitator2)
          assessment.update(response: @response)
        end

        it 'returns true when a response is submitted' do
          @response.update(submitted_at: Time.now)
          expect(assessment.response_submitted?).to eq(true)
        end

        it 'returns false when a response isnt submitted' do
          expect(assessment.response_submitted?).to eq(false)
        end
      end

      describe '#percent_completed' do
        it 'gets 0% complete' do
          expect(assessment.percent_completed).to eq(0.0)
        end

        it 'gets 50% complete' do
          @response.update(submitted_at: Time.now)
          expect(assessment.percent_completed).to eq(50.0)
        end

        it 'gets 100% complete' do
          Response.create(responder_type: 'Participant', 
                          responder: @participant2,
                          submitted_at: Time.now)

          @response.update(submitted_at: Time.now)
          expect(assessment.percent_completed).to eq(100.0)
        end
      end
    end
  end

end
