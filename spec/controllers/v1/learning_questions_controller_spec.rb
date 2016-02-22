require 'spec_helper'

describe V1::LearningQuestionsController do
  render_views

  describe 'POST #create' do
    context 'when not signed in' do

      let(:assessment) {
        create(:assessment)
      }

      before(:each) do
        post :create, assessment_id: assessment.id, learning_question: {body: 'This is my question.  Does it end in a question mark?'}, format: :json
      end

      it 'sends a message telling the user to authenticate' do
        expect(json['error']).to eq 'You need to sign in or sign up before continuing.'
      end
    end

    context 'when signed in' do
      context 'when not a part of the assessment' do

        let(:assessment) {
          create(:assessment)
        }

        let(:user) {
          create(:user)
        }

        before(:each) do
          sign_in user
          post :create, assessment_id: assessment.id, learning_question: {body: 'This is my question.  Does it end in a question mark?'}, format: :json
        end

        after(:each) do
          sign_out user
        end

        it 'does not create an entity' do
          expect(LearningQuestion.where(user_id: user.id, assessment_id: assessment.id).first).to be_nil
        end

        it 'sends back a descriptive error' do
          expect(json['errors']).to eq 'User is not a part of this assessment'
        end
      end

      context 'when the user is the owner of the assessment' do

        let(:user) {
          create(:user)
        }

        let(:assessment) {
          create(:assessment, user: user)
        }

        before(:each) do
          sign_in user
          post :create, assessment_id: assessment.id, learning_question: {body: 'This is my question.  Does it end in a question mark?'}, format: :json
        end

        it 'creates an entity' do
          expect(LearningQuestion.where(user_id: user.id, assessment_id: assessment.id).first).to_not be_nil
        end

        it 'sends back the full entity JSON' do
          expect(json['user_id']).to eq user.id
          expect(json['assessment_id']).to eq assessment.id
          expect(json['body']).to eq 'This is my question.  Does it end in a question mark?'
        end
      end

      context 'when the user is a participant' do

        let(:assessment) {
          create(:assessment, :with_participants)
        }

        let(:user) {
          assessment.participants.first.user
        }

        before(:each) do
          sign_in user
          post :create, assessment_id: assessment.id, learning_question: {body: 'This is my question.  Does it end in a question mark?'}, format: :json
        end

        it 'creates an entity' do
          expect(LearningQuestion.where(user_id: user.id, assessment_id: assessment.id).first).to_not be_nil
        end

        it 'sends back the full entity JSON' do
          expect(json['user_id']).to eq user.id
          expect(json['assessment_id']).to eq assessment.id
          expect(json['body']).to eq 'This is my question.  Does it end in a question mark?'
          expect(json['id']).to_not be_nil
        end
      end

      context 'when no body is provided' do

        let(:user) {
          create(:user)
        }

        let(:assessment) {
          create(:assessment, user: user)
        }

        before(:each) do
          sign_in user
          post :create, assessment_id: assessment.id, learning_question: {body: ''}, format: :json
        end

        it 'does not create an entity' do
          expect(LearningQuestion.where(user_id: user.id, assessment_id: assessment.id).first).to be_nil
        end

        it 'sends back a descriptive error' do
          expect(json['errors']['body'][0]).to eq "can't be blank"
        end
      end
    end
  end

  describe 'GET #index' do
    context 'when not signed in' do

      let(:assessment) {
        create(:assessment)
      }

      before(:each) do
        get :index, assessment_id: assessment.id, format: :json
      end

      it 'sends a message telling the user to authenticate' do
        expect(json['error']).to eq 'You need to sign in or sign up before continuing.'
      end
    end

    context 'when signed in' do
      context 'when not a part of the assessment' do
        let(:assessment) {
          create(:assessment)
        }

        before(:each) do
          get :index, assessment_id: assessment.id, format: :json
        end

        let(:user) {
          create(:user)
        }

        before(:each) do
          sign_in user
          get :index, assessment_id: assessment.id, format: :json
        end

        it 'sends an error message' do
          expect(json['errors']).to eq 'You are not a part of this assessment, so you cannot see any learning questions.'
        end
      end

      context 'when the user is the owner of the assessment' do

        let(:user) {
          create(:user)
        }

        let(:assessment) {
          create(:assessment, user: user)
        }

        let!(:learning_question_state) {
          create_list(:learning_question, 5, assessment: assessment)
        }

        before(:each) do
          sign_in user
          get :index, assessment_id: assessment.id, format: :json
        end

        it 'has the right count of entities' do
          expect(json['learning_questions'].size).to eq 5
        end

        it 'has an assessment id' do
          expect(json['learning_questions'][0]['assessment_id']).to_not be_nil
        end

        it 'has a user id' do
          expect(json['learning_questions'][0]['user_id']).to_not be_nil
        end

        it 'has a body' do
          expect(json['learning_questions'][0]['body']).to_not be_nil
        end

        it 'has an ID' do
          expect(json['learning_questions'][0]['id']).to_not be_nil
        end
      end

      context 'when the user is a participant of the assessment' do

        let(:user) {
          create(:user)
        }

        let(:assessment) {
          create(:assessment, :with_participants)
        }

        let(:participant) {
          assessment.participants.first.user
        }

        let!(:learning_question_state) {
          create_list(:learning_question, 5, assessment: assessment)
        }

        before(:each) do
          sign_in participant
          get :index, assessment_id: assessment.id, format: :json
        end

        it 'has the right count of entities' do
          expect(json['learning_questions'].size).to eq 5
        end

        it 'has an assessment id' do
          expect(json['learning_questions'][0]['assessment_id']).to_not be_nil
        end

        it 'has a user id' do
          expect(json['learning_questions'][0]['user_id']).to_not be_nil
        end

        it 'has a body' do
          expect(json['learning_questions'][0]['body']).to_not be_nil
        end

        it 'has an ID' do
          expect(json['learning_questions'][0]['id']).to_not be_nil
        end
      end
    end
  end

  describe 'PATCH #update' do
    context 'when not signed in' do
      let(:learning_question) {
        create(:learning_question)
      }

      before(:each) do
        patch :update, assessment_id: learning_question.assessment.id, id: learning_question.id, format: :json
      end

      it 'sends a message telling the user to authenticate' do
        expect(json['error']).to eq 'You need to sign in or sign up before continuing.'
      end
    end

    context 'when signed in' do
      context 'when attempting to edit a question that does not belong to its creator' do
        let(:learning_question) {
          create(:learning_question)
        }

        let(:assessment) {
          learning_question.assessment
        }

        let(:user) {
          create(:user)
        }

        before(:each) do
          sign_in user
          patch :update, assessment_id: assessment.id, id: learning_question.id, learning_question: {body: ''}, format: :json
        end

        it 'provides a helpful message in JSON' do
          expect(json['errors']).to eq 'You may not edit a learning question that you did not create.'
        end

        it 'responds with a bad request error code' do
          expect(response.status).to eq 400
        end
      end
      context 'when attempting to edit a question that belongs to its creator' do
        context 'when passing in a blank body' do
          let(:learning_question) {
            create(:learning_question)
          }

          let(:user) {
            learning_question.user
          }

          before(:each) do
            sign_in user
            patch :update, assessment_id: learning_question.assessment.id, id: learning_question.id, learning_question: {body: ''}, format: :json
          end

          it 'rejects the edit' do
            expect(response.status).to eq 400
          end

          it 'does not change the entity' do
            expect(learning_question.body).not_to eq ''
          end
        end

        context 'when passing in a non-blank body' do
          let(:learning_question) {
            create(:learning_question)
          }

          let(:user) {
            learning_question.user
          }

          before(:each) do
            sign_in user
            patch :update, assessment_id: learning_question.assessment.id, id: learning_question.id, learning_question: {body: 'This is a fix!'}, format: :json
          end

          it 'accepts the edit' do
            expect(response.status).to eq 204
          end

          it 'modifies the entity' do
            learning_question.reload
            expect(learning_question.body).to eq 'This is a fix!'
          end
        end
      end
    end
  end
end
