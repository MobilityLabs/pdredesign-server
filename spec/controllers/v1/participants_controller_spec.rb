require 'spec_helper'

describe V1::ParticipantsController do
  render_views

  before(:each) do
    request.env["HTTP_ACCEPT"] = 'application/json'
  end

  describe 'GET #index' do
    context 'when not authenticated' do

      let(:assessment) {
        create(:assessment, :with_participants)
      }

      before(:each) do
        sign_out :user
        get :index, params: { assessment_id: assessment.id }
      end

      it {
        is_expected.to respond_with :unauthorized
      }
    end

    context 'when authenticated' do
      let(:assessment) {
        create(:assessment, :with_participants)
      }

      let(:user) {
        assessment.user
      }

      before(:each) do
        sign_in user
        get :index, params: { assessment_id: assessment.id }
      end

      it {
        is_expected.to respond_with :success
      }

      it 'gets a list of participants' do
        participants = assigns(:participants)
        expect(participants.count).to eq 2
      end
    end
  end

  describe 'POST #create' do
    context 'when not authenticated' do

      let(:assessment) {
        create(:assessment, :with_participants)
      }

      before(:each) do
        sign_out :user
        post :create, params: { assessment_id: assessment.id }
      end

      it {
        is_expected.to respond_with :unauthorized
      }
    end

    context 'when authenticated' do
      context 'when not the owner of the assessment' do

        let(:user) {
          create(:user)
        }

        let(:assessment) {
          create(:assessment, :with_participants)
        }

        before(:each) do
          sign_in user
          post :create, params: { assessment_id: assessment.id, user_id: user.id }
        end

        it {
          is_expected.to respond_with :forbidden
        }
      end

      context 'when the owner of the assessment' do
        let(:assessment) {
          create(:assessment, :with_participants)
        }

        let(:user) {
          create(:user)
        }

        let(:facilitator) {
          assessment.user
        }

        context 'when :send_invite is true' do
          before(:each) do
            sign_in facilitator
            double = double('AssessmentMailer')

            expect(double).to receive(:deliver_now)
            expect(AssessmentsMailer).to receive(:assigned).and_return(double)

            post :create, params: { assessment_id: assessment.id, user_id: user.id, send_invite: true }
          end

          it {
            is_expected.to respond_with :success
          }
        end

        context 'when :send_invite is not true' do
          before(:each) do
            sign_in facilitator
            post :create, params: { assessment_id: assessment.id, user_id: user.id }
          end

          it {
            is_expected.to respond_with :success
          }

          it 'creates a participant' do
            participants = Participant.where(assessment_id: assessment.id, user_id: user.id)
            expect(participants.count).to eq 1
          end
        end
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:assessment) {
      create(:assessment, :with_participants)
    }

    let(:participant) {
      assessment.participants.first
    }

    let(:user) {
      assessment.user
    }

    context 'when there are no pending invitations for the participant' do
      before(:each) do
        sign_in user
        delete :destroy, params: { assessment_id: assessment.id, id: participant.id }
      end

      it {
        is_expected.to respond_with :success
      }

      it {
        expect(Participant.where(id: participant.id)).to be_empty
      }
    end

    context 'when there is a pending invitation for the participant' do
      let!(:user_invitation) {
        create(:user_invitation,
               user_id: user.id,
               email: participant.user.email,
               assessment_id: assessment.id)
      }

      before(:each) do
        sign_in user
        delete :destroy, params: { assessment_id: assessment.id, id: participant.id }
      end

      it {
        expect(UserInvitation.where(user_id: user.id)).to be_empty
      }
    end

    context 'when the participant is not associated with this assessment' do
      before(:each) do
        sign_in user
        delete :destroy, params: { assessment_id: assessment.id, id: 0 }
      end

      it {
        is_expected.to respond_with :missing
      }
    end

    context 'when not the owner of the assessment' do
      let(:non_owner) {
        create(:user)
      }

      before(:each) do
        sign_in non_owner
        delete :destroy, params: { assessment_id: assessment.id, id: participant.id }
      end

      it {
        is_expected.to respond_with :forbidden
      }
    end
  end

  describe 'GET #all' do

    let(:assessment) {
      create(:assessment, :with_participants)
    }

    context 'when the user is not a facilitator' do
      let(:user) {
        assessment.participants.first.user
      }

      before(:each) do
        sign_in user
        get :all, params: { assessment_id: assessment.id }
      end

      it {
        is_expected.to respond_with :forbidden
      }
    end

    context 'when the user is a facilitator' do
      let(:user) {
        assessment.user
      }

      let!(:users_not_associated_with_assessment) {
        create_list(:user, 2, districts: [assessment.district])
      }

      before(:each) do
        sign_in user
        get :all, params: { assessment_id: assessment.id }
      end

      it 'gives a list of all participants in assessment district' do
        participants = assigns(:users)
        expect(participants.count).to eq 2
      end


      it 'does not return participants already in assessment' do
        participants = assigns(:users)
        expect(participants.to_set.intersect? assessment.participants.to_set).to be false
      end

      context 'when network partners are part of this district' do
        let!(:network_partners_not_associated_with_district) {
          create_list(:user, 3, :with_network_partner_role, districts: [assessment.district])
        }

        before(:each) do
          sign_in user
          get :all, params: { assessment_id: assessment.id }
        end

        it 'does not include them' do
          participants = assigns(:users)
          expect(participants.to_set.intersect? network_partners_not_associated_with_district.to_set).to be false
        end
      end
    end
  end

  describe 'GET #mail' do
    let(:assessment) {
      create(:assessment, :with_participants)
    }

    context 'when the user is not a facilitator' do
      let(:user) {
        assessment.participants.first.user
      }

      before(:each) do
        sign_in user
        get :mail, params: { assessment_id: assessment.id, participant_id: assessment.participants.first.id }
      end

      it {
        is_expected.to respond_with :forbidden
      }
    end

    context 'when the user is a facilitator' do
      let(:user) {
        assessment.user
      }

      let(:participant) {
        assessment.participants.first
      }

      before(:each) do
        sign_in user
        get :mail, params: { assessment_id: assessment.id, participant_id: participant.id }
      end

      it {
        is_expected.to respond_with :success
      }

      context 'when the participant does not belong to that assessment' do
        let(:user) {
          assessment.user
        }

        before(:each) do
          sign_in user
          get :mail, params: { assessment_id: assessment.id, participant_id: 0 }
        end

        it {
          is_expected.to respond_with :missing
        }
      end

      context 'when inspecting the invitation email' do

        let!(:user_invitation) {
          create(:user_invitation, user: participant.user, assessment: assessment)
        }

        before(:each) do
          sign_in user

          double = double('AssessmentMailer', text_part: OpenStruct.new(body: 'expected'))
          allow(AssessmentInvitationMailer).to receive(:invite).and_return(double)
          allow(AssessmentsMailer).to receive(:assigned).and_return(double)

          get :mail, params: { assessment_id: assessment.id, participant_id: participant.id }
        end

        it 'returns the invitation email body of assigned email' do
          expect(response.body).to eq('expected')
        end

        it 'returns the invitation email body of the user invitation email' do
          expect(response.body).to eq('expected')
        end
      end
    end
  end
end
