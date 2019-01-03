shared_examples_for 'a learning controller' do |tool_sym|
  describe 'POST #create' do
    context 'when not signed in' do

      let(:tool) {
        create(tool_sym)
      }

      before(:each) do
        post :create, params: {
          "#{tool_sym}_id": tool.id,
          learning_question: { body: 'This is my question.  Does it end in a question mark?' }
        }, as: :json
      end

      it 'sends a message telling the user to authenticate' do
        expect(json['error']).to eq 'You need to sign in or sign up before continuing.'
      end
    end

    context 'when signed in' do
      context 'when not a part of the assessment' do

        let(:tool) {
          create(tool_sym)
        }

        let(:user) {
          create(:user)
        }

        before(:each) do
          sign_in user
          post :create, params: {
            "#{tool_sym}_id": tool.id,
            learning_question: {body: 'This is my question.  Does it end in a question mark?'}
          }, as: :json
        end

        after(:each) do
          sign_out user
        end

        it 'does not create an entity' do
          expect(LearningQuestion.where(user_id: user.id, tool_id: tool.id).first).to be_nil
        end

        it 'sends back a descriptive error' do
          expect(json['errors']).to eq 'User is not a part of this assessment'
        end
      end

      context 'when the user is the owner of the assessment' do

        let(:user) {
          create(:user)
        }

        let(:tool) {
          create(tool_sym, user: user)
        }

        before(:each) do
          sign_in user
          post :create, params: {
            "#{tool_sym}_id": tool.id, learning_question: {body: 'This is my question.  Does it end in a question mark?'}
          }, as: :json
        end

        it 'creates an entity' do
          expect(LearningQuestion.where(user_id: user.id, tool_id: tool.id).first).to_not be_nil
        end

        it 'sends back the full entity JSON' do
          expect(json['user_id']).to eq user.id
          expect(json['tool_id']).to eq tool.id
          expect(json['body']).to eq 'This is my question.  Does it end in a question mark?'
        end
      end

      context 'when the user is a participant' do

        let(:tool) {
          create(tool_sym, :with_participants)
        }

        let(:user) {
          tool.participants.first.user
        }

        before(:each) do
          sign_in user
          post :create, params: {
            "#{tool_sym}_id": tool.id, learning_question: {body: 'This is my question.  Does it end in a question mark?'}
          }, as: :json
        end

        it 'creates an entity' do
          expect(LearningQuestion.where(user_id: user.id, tool_id: tool.id).first).to_not be_nil
        end

        it 'sends back the full entity JSON' do
          expect(json['user_id']).to eq user.id
          expect(json['tool_id']).to eq tool.id
          expect(json['body']).to eq 'This is my question.  Does it end in a question mark?'
          expect(json['id']).to_not be_nil
        end
      end

      context 'when no body is provided' do

        let(:user) {
          create(:user)
        }

        let(:tool) {
          create(tool_sym, user: user)
        }

        before(:each) do
          sign_in user
          post :create, params: { "#{tool_sym}_id": tool.id, learning_question: {body: ''} }, as: :json
        end

        it 'does not create an entity' do
          expect(LearningQuestion.where(user_id: user.id, tool_id: tool.id).first).to be_nil
        end

        it 'sends back a descriptive error' do
          expect(json['errors']['body'][0]).to eq "can't be blank"
        end
      end
    end
  end

  describe 'GET #index' do
    context 'when not signed in' do

      let(:tool) {
        create(tool_sym)
      }

      before(:each) do
        get :index, params: { "#{tool_sym}_id": tool.id }, as: :json
      end

      it 'sends a message telling the user to authenticate' do
        expect(json['error']).to eq 'You need to sign in or sign up before continuing.'
      end
    end

    context 'when signed in' do
      context 'when not a part of the assessment' do
        let(:tool) {
          create(tool_sym)
        }

        before(:each) do
          get :index, params: { "#{tool_sym}_id": tool.id }, as: :json
        end

        let(:user) {
          create(:user)
        }

        before(:each) do
          sign_in user
          get :index, params: { "#{tool_sym}_id": tool.id }, as: :json
        end

        it 'sends an error message' do
          expect(json['errors']).to eq 'You are not a part of this assessment, so you cannot see any learning questions.'
        end
      end

      context 'when the user is the owner of the assessment' do

        let(:user) {
          create(:user)
        }

        let(:tool) {
          create(tool_sym, user: user)
        }

        let!(:learning_question_state) {
          create_list(:learning_question, 5, tool: tool)
        }

        before(:each) do
          sign_in user
          get :index, params: { "#{tool_sym}_id": tool.id }, as: :json
        end

        it 'has the right count of entities' do
          expect(json['learning_questions'].size).to eq 5
        end

        it 'has a tool id' do
          expect(json['learning_questions'][0]['tool_id']).to_not be_nil
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
        context 'when the user has created all learning questions' do

          let(:tool) {
            create(tool_sym, :with_participants)
          }

          let(:participant) {
            tool.participants.first.user
          }

          let!(:learning_question_state) {
            create_list(:learning_question, 5, tool: tool, user: participant)
          }

          before(:each) do
            sign_in participant
            get :index, params: { "#{tool_sym}_id": tool.id }, as: :json
          end

          it 'has the right count of entities' do
            expect(json['learning_questions'].size).to eq 5
          end

          it 'has a tool id' do
            expect(json['learning_questions'][0]['tool_id']).to_not be_nil
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

          it 'has different IDs' do
            expect(json['learning_questions'].uniq { |result| result['id'] }.size).to eq 5
          end

          it 'has an editable field' do
            expect(json['learning_questions'][0]['editable']).to_not be_nil
          end

          it 'indicates that all questions are editable' do
            expect(json['learning_questions'].all? { |result| result['editable'] }).to be true
          end
        end

        context 'when the user has created none of the learning questions' do

          let(:tool) {
            create(tool_sym, :with_participants)
          }

          let(:participant) {
            tool.participants.first.user
          }

          let!(:learning_question_state) {
            create_list(:learning_question, 5, tool: tool)
          }

          before(:each) do
            sign_in participant
            get :index, params: { "#{tool_sym}_id": tool.id }, as: :json
          end

          it 'has the right count of entities' do
            expect(json['learning_questions'].size).to eq 5
          end

          it 'has a tool id' do
            expect(json['learning_questions'][0]['tool_id']).to_not be_nil
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

          it 'has an editable field' do
            expect(json['learning_questions'][0]['editable']).to_not be_nil
          end

          it 'indicates that none of the questions are editable' do
            expect(json['learning_questions'].all? { |result| result['editable'] }).to be false
          end
        end
      end
    end
  end

  describe 'PATCH #update' do
    context 'when not signed in' do
      let(:learning_question) {
        create(:learning_question, "with_#{tool_sym}".to_sym,)
      }

      let(:tool) {
        learning_question.tool
      }

      before(:each) do
        patch :update, params: { "#{tool_sym}_id": tool.id, id: learning_question.id }, as: :json
      end

      it 'sends a message telling the user to authenticate' do
        expect(json['error']).to eq 'You need to sign in or sign up before continuing.'
      end
    end

    context 'when signed in' do
      context 'when attempting to edit a question that does not belong to the current user' do
        let(:learning_question) {
          create(:learning_question, "with_#{tool_sym}".to_sym)
        }

        let(:tool) {
          learning_question.tool
        }

        let(:user) {
          create(:user)
        }

        before(:each) do
          sign_in user
          patch :update, params: { "#{tool_sym}_id": tool.id, id: learning_question.id, learning_question: {body: ''} }, as: :json
        end

        it 'provides a helpful message in JSON' do
          expect(json['errors']).to eq 'You may not edit a learning question that you did not create.'
        end

        it 'responds with a bad request error code' do
          expect(response.status).to eq 400
        end
      end

      context 'when attempting to edit a question that belongs to the current user' do
        context 'when passing in a blank body' do
          let(:learning_question) {
            create(:learning_question, "with_#{tool_sym}".to_sym)
          }

          let(:tool) {
            learning_question.tool
          }

          let(:user) {
            learning_question.user
          }

          before(:each) do
            sign_in user
            patch :update, params: { "#{tool_sym}_id": tool.id, id: learning_question.id, learning_question: {body: ''} }, as: :json
          end

          it 'rejects the edit' do
            expect(response.status).to eq 400
          end

          it 'does not change the entity' do
            expect(learning_question.body).not_to eq ''
          end

          it 'provides a helpful response in JSON' do
            expect(json['errors']['body'][0]).to eq "can't be blank"
          end
        end

        context 'when passing in a non-blank body' do
          let(:learning_question) {
            create(:learning_question, "with_#{tool_sym}".to_sym)
          }

          let(:tool) {
            learning_question.tool
          }

          let(:user) {
            learning_question.user
          }

          before(:each) do
            sign_in user
            patch :update, params: { "#{tool_sym}_id": tool.id, id: learning_question.id, learning_question: {body: 'This is a fix!'} }, as: :json
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

  describe 'DELETE #destroy' do
    context 'when not signed in' do

      let(:learning_question) {
        create(:learning_question, "with_#{tool_sym}".to_sym)
      }

      let(:tool) {
        learning_question.tool
      }

      before(:each) do
        delete :destroy, params: { "#{tool_sym}_id": tool.id, id: learning_question.id }, as: :json
      end

      it 'sends a message telling the user to authenticate' do
        expect(json['error']).to eq 'You need to sign in or sign up before continuing.'
      end
    end

    context 'when signed in' do
      context 'when attempting to delete a question that does not belong to the current user' do

        let(:learning_question) {
          create(:learning_question, "with_#{tool_sym}".to_sym)
        }

        let(:tool) {
          learning_question.tool
        }

        let(:user) {
          create(:user)
        }

        before(:each) do
          sign_in user
          delete :destroy, params: { "#{tool_sym}_id": tool.id, id: learning_question.id }, as: :json
        end

        it 'provides a helpful message in JSON' do
          expect(json['errors']).to eq 'You may not delete a learning question that does not belong to you.'
        end

        it 'responds with a bad request error code' do
          expect(response.status).to eq 400
        end
      end

      context 'when attempting to delete a question belongs to the current user' do

        let(:learning_question) {
          create(:learning_question, "with_#{tool_sym}".to_sym)
        }

        let(:tool) {
          learning_question.tool
        }

        let(:user) {
          learning_question.user
        }

        before(:each) do
          sign_in user
          delete :destroy, params: { "#{tool_sym}_id": tool.id, id: learning_question.id }, as: :json
        end

        it 'responds with a no content response code' do
          expect(response.status).to eq 204
        end
      end
    end
  end

  describe 'GET #exists' do
    context 'when the user has not created any learning questions' do
      let(:user) {
        create(:user)
      }

      let(:tool) {
        create(tool_sym)
      }

      before(:each) do
        sign_in user
        get :exists, params: { "#{tool_sym}_id": tool.id }
      end

      it { is_expected.to respond_with 404 }
    end

    context 'when the user has created a learning question, but not for the current assessment' do
      let!(:first_learning_question) {
        create(:learning_question, "with_#{tool_sym}".to_sym)
      }

      let!(:other_learning_question) {
        create(:learning_question, "with_#{tool_sym}".to_sym, user: user)
      }

      let(:tool) {
        first_learning_question.tool
      }

      let(:user) {
        create(:user)
      }

      let(:other_user) {
        create(:user)
      }

      before(:each) do
        sign_in other_user
        get :exists, params: { "#{tool_sym}_id": tool.id }
      end


      it { is_expected.to respond_with 404 }
    end

    context 'when the user has created a learning question for the current assessment' do

      let(:learning_question) {
        create(:learning_question, "with_#{tool_sym}".to_sym)
      }

      let(:tool) {
        learning_question.tool
      }

      let(:user) {
        learning_question.user
      }

      before(:each) do
        sign_in user
        get :exists, params: { "#{tool_sym}_id": tool.id }
      end

      it { is_expected.to respond_with 200 }
    end
  end
end
