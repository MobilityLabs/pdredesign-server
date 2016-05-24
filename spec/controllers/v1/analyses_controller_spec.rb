require 'spec_helper'

describe V1::AnalysesController do
  render_views

  let(:inventory) { FactoryGirl.create(:inventory, :with_analysis) }
  let(:analysis) { inventory.analyses.first }

  before :each do
    request.env['HTTP_ACCEPT'] = 'application/json'
  end

  context '#index' do
    it 'requires logged in user' do
      sign_out :user

      get :index, inventory_id: inventory.id
      expect(response).to have_http_status(:unauthorized)
    end

    it "gets an inventory's analysis" do
      sign_in inventory.owner

      get :index, inventory_id: inventory.id

      expect(response).to have_http_status(:ok)
    end
  end

  context '#create' do
    let!(:rubric) {
      create(:rubric, version: 1, tool_type: 'Analysis')
    }

    it 'requires logged in user' do
      sign_out :user

      post :create, inventory_id: inventory.id
      expect(response).to have_http_status(:unauthorized)
    end

    it 'creates a record' do
      sign_in inventory.owner

      post :create,
           inventory_id: inventory.id,
           name: "name",
           deadline: '2042-11-14T00:00:00Z'

      expect(response).to have_http_status(:created)
      expect(json['id']).not_to be_nil
      expect(Analysis.where(id:json['id']).first).not_to be_nil
      expect(Analysis.where(id:json['id']).first.owner).to eq inventory.owner
    end
  end

  context '#update' do
    it 'requires logged in user' do
      sign_out :user

      put :update, inventory_id: inventory.id
      expect(response).to have_http_status(:unauthorized)
    end

    it 'updates a record' do
      sign_in inventory.owner

      put :update,
          inventory_id: inventory.id,
          id: analysis.id,
          name: 'name',
          deadline: '2042-11-14T00:00:00Z'

      expect(response).to have_http_status(:no_content)
    end

    it 'does not set :assigned_at' do
      sign_in inventory.owner

      put :update,
          inventory_id: inventory.id,
          id: analysis.id

      expect(response).to have_http_status(:no_content)

      updated_analysis = Analysis.find(analysis.id)
      expect(updated_analysis.assigned_at).to be_nil
    end

    it 'sets :assigned_at when :assign present' do
      sign_in inventory.owner

      put :update,
          inventory_id: inventory.id,
          id: analysis.id,
          assign: true

      expect(response).to have_http_status(:no_content)

      updated_analysis = Analysis.find(analysis.id)
      expect(updated_analysis.assigned_at).not_to be_nil
    end

    it 'sends the invitation email to all participants' do
      sign_in inventory.owner

      expect(AllAnalysisParticipantsNotificationWorker).to receive(:perform_async)
                                                       .with(analysis.id)

      put :update,
          inventory_id: inventory.id,
          id: analysis.id,
          message: "some custom message here",
          assign: true

      expect(response).to have_http_status(:no_content)
    end
  end
end
