require 'spec_helper'

describe V1::ScoresController do
  render_views
  before(:each) do
    request.env['HTTP_ACCEPT'] = 'application/json'
  end

  describe 'POST #create' do
    context 'when unauthenticated' do
      before(:each) do
        post :create, params: {
          assessment_id: 9000,
          response_id: 9001,
          question_id: 9001,
          value: 4,
          evidence: 'foo'
        }
      end

      it { expect(response.status).to eq 401 }
    end

    context 'when authenticated' do
      let(:user) {
        create(:user)
      }

      context 'when the tool is an assessment' do
        let(:tool) {
          create(:assessment, :with_participants, user: user)
        }

        let(:response_obj) {
          create(:response, responder: tool)
        }

        let(:question) {
          create(:question)
        }

        context 'when the score does not exist' do
          before(:each) do
            sign_in user
            post :create, params: {
              assessment_id: tool.id,
              response_id: response_obj.id,
              question_id: question.id,
              value: 1,
              evidence: 'new score'
            }
          end

          it 'creates a score' do
            expect(Score.where(response_id: response_obj.id, question_id: question.id, evidence: 'new score').first).to_not be_nil
          end

          it { is_expected.to use_after_action(:flush_assessment_cache) }
        end

        context 'when the evidence is blank' do
          before(:each) do
            sign_in user
            post :create, params: {
              assessment_id: tool.id,
              response_id: response_obj.id,
              question_id: question.id,
              value: 1,
              evidence: nil
            }, as: :json
          end

          it 'creates a score' do
            expect(Score.where(response_id: response_obj.id, question_id: question.id, evidence: nil).first).to_not be_nil
          end

          it { is_expected.to use_after_action(:flush_assessment_cache) }
        end

        context 'when the score already exists' do
          let!(:existing_score) {
            create(:score, value: 1, response: response_obj, question: question, evidence: 'old score')
          }

          before(:each) do
            sign_in user
            post :create, params: {
              assessment_id: tool.id,
              response_id: response_obj.id,
              question_id: question.id,
              value: 3,
              evidence: 'overwriting score'
            }
          end

          it 'updates the score' do
            expect(Score.where(response_id: response_obj.id, question_id: question.id).first.evidence).to eq 'overwriting score'
            expect(Score.where(response_id: response_obj.id, question_id: question.id).first.value).to eq 3
          end

          it 'returns no content' do
            expect(response.status).to eq 204
          end

          it { is_expected.to use_after_action(:flush_assessment_cache) }
        end
      end

      context 'when the tool is an analysis' do
        let(:facilitator) {
          tool.facilitators.first
        }

        let(:tool) {
          create(:analysis, :with_facilitators, inventory: create(:inventory))
        }

        let(:response_obj) {
          create(:response, :as_analysis_response, responder: tool)
        }

        let(:question) {
          create(:question)
        }

        let(:params) {
          {
              inventory_id: tool.inventory.id,
              analysis_id: tool.id,
              analysis_response_id: response_obj.id,
              question_id: question.id,
              value: 1,
              supporting_inventory_response_attributes: {
                  product_entries: [1, 2, 3],
                  data_entries: [4, 5, 6],
                  product_entry_evidence: 'This is product evidence',
                  data_entry_evidence: 'This is data evidence'
              }
          }
        }

        context 'when the score does not exist' do
          before(:each) do
            sign_in tool.inventory.owner
            post :create, params: params
          end

          it 'creates a score' do
            expect(Score.where(response_id: response_obj.id, question_id: question.id).first).to_not be_nil
          end

          it 'creates the supporting inventory response with the right data' do
            score = Score.where(response_id: response_obj.id, question_id: question.id).first
            expect(score.supporting_inventory_response).to_not be_nil
            expect(score.supporting_inventory_response.product_entries).to eq [1, 2, 3]
            expect(score.supporting_inventory_response.data_entries).to eq [4, 5, 6]
            expect(score.supporting_inventory_response.product_entry_evidence).to eq 'This is product evidence'
            expect(score.supporting_inventory_response.data_entry_evidence).to eq 'This is data evidence'
          end

          it { is_expected.to use_after_action(:flush_assessment_cache) }
        end

        context 'when the supporting inventory response is blank' do
          before(:each) do
            sign_in tool.inventory.owner
            post :create, params: {
              inventory_id: tool.inventory.id,
              analysis_id: tool.id,
              analysis_response_id: response_obj.id,
              question_id: question.id,
              value: 1,
              supporting_inventory_response_attributes: {}
            }, as: :json
          end

          it 'creates a score with blank supporting inventory response data' do
            score = Score.where(response_id: response_obj.id, question_id: question.id).first
            expect(score.supporting_inventory_response).to_not be_nil
            expect(score.supporting_inventory_response.product_entries).to be_empty
            expect(score.supporting_inventory_response.data_entries).to be_empty
            expect(score.supporting_inventory_response.product_entry_evidence).to be_nil
            expect(score.supporting_inventory_response.data_entry_evidence).to be_nil
          end

          it { is_expected.to use_after_action(:flush_assessment_cache) }
        end

        context 'when the score already exists' do
          let(:supporting_inventory_response) {
            create(:supporting_inventory_response,
                   product_entries: [1, 2, 3],
                   data_entries: [1, 4, 18],
                   product_entry_evidence: 'Providence!',
                   data_entry_evidence: 'Rhode Island...'
            )
          }

          let!(:existing_score) {
            create(:score, value: 1, response: response_obj, question: question, supporting_inventory_response: supporting_inventory_response)
          }

          let(:params) {
            {
                inventory_id: tool.inventory.id,
                analysis_id: tool.id,
                analysis_response_id: response_obj.id,
                question_id: question.id,
                value: 4,
                supporting_inventory_response_attributes: {
                    product_entries: [21, 22, 33],
                    data_entries: [19, 254, 88],
                    product_entry_evidence: 'Bismarck?',
                    data_entry_evidence: 'North Dakota?!'
                }
            }
          }

          before(:each) do
            sign_in tool.inventory.owner
            post :create, params: params
          end

          it 'updates the score' do
            score = Score.where(response_id: response_obj.id, question_id: question.id).first
            expect(score.supporting_inventory_response.product_entries).to eq [21, 22, 33]
            expect(score.supporting_inventory_response.data_entries).to eq [19, 254, 88]
            expect(score.supporting_inventory_response.product_entry_evidence).to eq 'Bismarck?'
            expect(score.supporting_inventory_response.data_entry_evidence).to eq 'North Dakota?!'

            expect(score.value).to eq 4
          end

          it 'returns no content' do
            expect(response.status).to eq 204
          end

          it { is_expected.to use_after_action(:flush_assessment_cache) }
        end
      end
    end
  end

  describe 'GET #index' do
    context 'when unauthenticated' do
      before(:each) do
        post :create, params: {
          assessment_id: 9000,
          response_id: 9001
        }
      end

      it { expect(response.status).to eq 401 }
    end

    context 'when authenticated' do
      let(:user) {
        create(:user)
      }

      context 'when the tool is an assessment' do
        let(:tool) {
          create(:assessment, :with_participants, user: user, rubric: rubric)
        }

        let(:response_obj) {
          create(:response, responder: tool, rubric: rubric)
        }

        let!(:rubric) {
          create(:rubric, :as_assessment_rubric)
        }

        let(:category) {
          create(:category)
        }

        let!(:scores) {
          scores = create_list(:score, 9, response: response_obj)
          scores.each { |score|
            score.question = create(:question, rubrics: [rubric], category: category)
            rubric.questions << score.question
            score.save!
          }
          scores
        }

        before(:each) do
          sign_in user
          get :index, params: {
            assessment_id: tool.id,
            response_id: response_obj.id
          }
        end

        it 'gives a list of scores for each question' do
          expect(json.count).to eq(9)
        end

        it 'gives a score for each question' do
          first = json.detect { |q| q["id"] == scores.first.question.id }
          expect(first["score"]["id"]).to eq(scores.first.id)
        end
      end

      context 'when the tool is an analysis' do
        let(:facilitator) {
          tool.facilitators.first
        }

        let(:tool) {
          create(:analysis, :with_facilitators, rubric: rubric)
        }

        let(:response_obj) {
          create(:response, responder: tool, rubric: rubric)
        }

        let!(:rubric) {
          create(:rubric, :as_analysis_rubric)
        }

        let(:category) {
          create(:category)
        }

        let!(:scores) {
          scores = create_list(:score, 9, :with_supporting_inventory_response, response: response_obj)
          scores.each { |score|
            score.question = create(:question, rubrics: [rubric], category: category)
            rubric.questions << score.question
            score.save!
          }
          scores
        }

        before(:each) do
          sign_in user
          get :index, params: {
            inventory_id: tool.inventory.id,
            analysis_id: tool.id,
            analysis_response_id: response_obj.id
          }
        end

        it 'gives a list of scores for each question' do
          expect(json.count).to eq(9)
        end

        it 'gives a score for each question' do
          first = json.detect { |q| q["id"] == scores.first.question.id }
          expect(first["score"]["id"]).to eq(scores.first.id)
        end

        it 'adds JSON for supporting inventory responses' do
          expect(json[0]['score']['supporting_inventory_response']).to_not be_nil
        end
      end
    end
  end
end
