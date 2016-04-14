require 'spec_helper'

describe V1::DataEntriesController do
  render_views

  let(:inventory) { FactoryGirl.create(:inventory, :with_data_entries) }

  before :each do
    request.env['HTTP_ACCEPT'] = 'application/json'
  end

  context '#index' do
    it 'requires logged in user' do
      sign_out :user

      get :index, inventory_id: inventory.id
      assert_response :unauthorized
    end

    it "gets an inventory's data entries" do
      sign_in inventory.owner
      get :index, inventory_id: inventory.id
      data_entries = assigns(:data_entries)

      assert_response :success
      expect(data_entries.count).to eq(inventory.data_entries.count)
    end
  end

  context '#show' do
    it 'requires logged in user' do
      sign_out :user

      get :show, inventory_id: inventory.id, id: inventory.data_entries.first.id
      assert_response :unauthorized
    end

    it "gets an inventory's specific data entry" do
      sign_in inventory.owner
      get :show, inventory_id: inventory.id, id: inventory.data_entries.first.id
      data_entry = assigns(:data_entry)

      assert_response :success
      expect(data_entry.id).to eq(inventory.data_entries.first.id)
    end
  end

  context '#create' do
    it 'requires logged in user' do
      sign_out :user

      post :create, inventory_id: inventory.id
      assert_response :unauthorized
    end

    it "doesn't create an incomplete data entry" do
      sign_in inventory.owner

      post :create, inventory_id: inventory.id
      assert_response 422
      expect(assigns(:data_entry).persisted?).to be(false)
    end

    it "returns json errors when a data entry can't be created" do
      sign_in inventory.owner

      post :create, inventory_id: inventory.id
      assert_response 422
      expect(json['errors'].values.flatten).to include("can't be blank")
    end

    it 'creates a record' do
      sign_in inventory.owner

      post :create,
           inventory_id: inventory.id,
           general_data_question_attributes: {
             data_capture: GeneralDataQuestion.data_capture_options.values.first
           },
           data_entry_question_attributes: {
             when_data_is_entered: DataEntryQuestion.data_entered_frequencies.values.first
           },
           data_access_question_attributes: {
             who_access_data: DataAccessQuestion.data_accessed_bies.values.first
           }

      assert_response 201
    end
  end

  context '#update' do
    let(:data_entry) { inventory.data_entries.first }

    it 'requires logged in user' do
      sign_out :user

      put :update, inventory_id: inventory.id, id: data_entry.id
      assert_response :unauthorized
    end

    it "returns json errors when a data entry can't be updated" do
      sign_in inventory.owner

      put :update,
          inventory_id: inventory.id,
          id: data_entry.id,
          general_data_question_attributes: {
            data_capture: 'derp'
          }

      assert_response 422
      expect(json['errors'].values.flatten).to include("'derp' not permissible")
    end

    it 'updates a record' do
      sign_in inventory.owner

      put :update,
          inventory_id: inventory.id,
          id: data_entry.id,
          data_access_question_attributes: {
            notes: 'other notes'
          }

      assert_response 200
      expect(data_entry.reload.data_access_question.notes).to eq('other notes')
    end
  end
end
