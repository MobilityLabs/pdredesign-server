require 'spec_helper'

describe V1::MessagesController do
  render_views

  let(:assessment) {
    create(:assessment, :with_participants)
  }

  let(:analysis) {
    create(:analysis, :with_participants)
  }

  let(:inventory) {
    create(:inventory, :with_participants)
  }

  describe 'GET #index' do
    let!(:messages) {
      create_list(:message, 10, tool: assessment)
      create_list(:message, 15, tool: inventory)
      create_list(:message, 3, tool: analysis)
    }

    context 'when not authenticated' do
      before(:each) do
        sign_out :user
        get :index, params: { assessment_id: assessment.id }, as: :json
      end

      it {
        is_expected.to respond_with :unauthorized
      }
    end

    context 'when authenticated' do
      context 'when newer messages exist' do
        let(:new_assessment) {
          create(:assessment, :with_participants)
        }

        let!(:first_message) {
          create(:message, tool: new_assessment, sent_at: 5.days.ago)
        }

        let!(:second_message) {
          create(:message, tool: new_assessment, sent_at: 4.days.ago)
        }

        let!(:third_message) {
          create(:message, tool: new_assessment, sent_at: 3.days.ago)
        }

        let!(:fourth_message) {
          create(:message, tool: new_assessment, sent_at: 2.days.ago)
        }

        let!(:fifth_message) {
          create(:message, tool: new_assessment, sent_at: 1.day.ago)
        }

        let(:user) {
          new_assessment.user
        }

        before(:each) do
          sign_in user
          get :index, params: { assessment_id: new_assessment.id }, as: :json
        end

        it {
          expect(Time.parse(json['messages'][0]['sent_at']).to_i).to eq fifth_message.sent_at.to_i
        }

        it {
          expect(Time.parse(json['messages'][1]['sent_at']).to_i).to eq fourth_message.sent_at.to_i
        }

        it {
          expect(Time.parse(json['messages'][2]['sent_at']).to_i).to eq third_message.sent_at.to_i
        }

        it {
          expect(Time.parse(json['messages'][3]['sent_at']).to_i).to eq second_message.sent_at.to_i
        }

        it {
          expect(Time.parse(json['messages'][4]['sent_at']).to_i).to eq first_message.sent_at.to_i
        }
      end

      context 'when fetching assessment messages' do
        let(:user) {
          assessment.user
        }

        before(:each) do
          sign_in user
          get :index, params: { assessment_id: assessment.id }, as: :json
        end

        it {
          expect(json['messages'].size).to eq 10
        }
      end

      context 'when fetching inventory messages' do
        let(:user) {
          inventory.owner
        }

        before(:each) do
          sign_in user
          get :index, params: { inventory_id: inventory.id }, as: :json
        end

        it {
          expect(json['messages'].size).to eq 15
        }
      end

      context 'when fetching analysis messages' do
        let(:user) {
          analysis.inventory.owner
        }

        before(:each) do
          sign_in user
          get :index, params: { analysis_id: analysis.id }, as: :json
        end

        it {
          expect(json['messages'].size).to eq 3
        }
      end
    end
  end

  describe 'POST #create' do
    context 'when not authenticated' do
      before(:each) do
        sign_out :user
        post :create, params: { analysis_id: analysis.id, message: 'This is my message!' }, as: :json
      end

      it {
        is_expected.to respond_with :unauthorized
      }
    end

    context 'when authenticated' do
      context 'when creating an assessment reminder' do
        let(:user) {
          assessment.user
        }

        before(:each) do
          sign_in user
          post :create, params: { assessment_id: assessment.id, message: 'This is the assessment message reminder!!' }, as: :json
        end

        it {
          is_expected.to respond_with :created
        }

        it {
          expect(ReminderNotificationWorker.jobs.length).to eq 1
        }

        it {
          expect(ReminderNotificationWorker.jobs.first['args']).to eq [assessment.id, 'Assessment', 'This is the assessment message reminder!!']
        }
      end

      context 'when creating an inventory reminder' do
        let(:user) {
          inventory.user
        }

        before(:each) do
          sign_in user
          post :create, params: { inventory_id: inventory.id, message: 'This is the inventory message reminder!!' }, as: :json
        end

        it {
          is_expected.to respond_with :created
        }

        it {
          expect(ReminderNotificationWorker.jobs.length).to eq 1
        }

        it {
          expect(ReminderNotificationWorker.jobs.first['args']).to eq [inventory.id, 'Inventory', 'This is the inventory message reminder!!']
        }
      end

      context 'when creating an analysis reminder' do
        let(:user) {
          analysis.inventory.user
        }

        before(:each) do
          sign_in user
          post :create, params: { analysis_id: analysis.id, message: 'This is the analysis message reminder!!' }, as: :json
        end

        it {
          is_expected.to respond_with :created
        }

        it {
          expect(ReminderNotificationWorker.jobs.length).to eq 1
        }

        it {
          expect(ReminderNotificationWorker.jobs.first['args']).to eq [analysis.id, 'Analysis', 'This is the analysis message reminder!!']
        }
      end
    end
  end
end
