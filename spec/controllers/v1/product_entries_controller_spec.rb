require 'spec_helper'

describe V1::ProductEntriesController do
  render_views

  let(:inventory) { FactoryGirl.create(:inventory, :with_product_entries) }

  before :each do
    request.env['HTTP_ACCEPT'] = 'application/json'
  end

  context '#index' do
    it 'requires logged in user' do
      sign_out :user

      get :index, params: { inventory_id: inventory.id }
      assert_response :unauthorized
    end

    context "gets an inventory's product entries" do
      before do
        sign_in inventory.owner
      end

      it 'in json' do
        get :index, params: { inventory_id: inventory.id }
        product_entries = assigns(:product_entries)

        assert_response :success
        expect(product_entries.count).to eq(inventory.product_entries.count)
      end

      it 'in csv' do
        get :index, params: { inventory_id: inventory.id }, format: :csv
        product_entries = assigns(:product_entries)

        assert_response :success
        expect(product_entries.count).to eq(inventory.product_entries.count)
        expect(response.headers["Content-Disposition"]).to eq("attachment; filename=product_entries.csv")
        expect(response.headers['Content-Type']).to eq('text/csv')
      end
    end
  end

  context '#show' do
    it 'requires logged in user' do
      sign_out :user

      get :show, params: { inventory_id: inventory.id, id: inventory.product_entries.first.id }
      assert_response :unauthorized
    end

    it "gets an inventory's specific product entry" do
      sign_in inventory.owner
      get :show, params: { inventory_id: inventory.id, id: inventory.product_entries.first.id }
      product_entry = assigns(:product_entry)

      assert_response :success
      expect(product_entry.id).to eq(inventory.product_entries.first.id)
    end
  end

  context '#create' do
    it 'requires logged in user' do
      sign_out :user

      post :create, params: { inventory_id: inventory.id }
      assert_response :unauthorized
    end

    it "doesn't create an incomplete product entry" do
      sign_in inventory.owner

      post :create, params: { inventory_id: inventory.id }
      assert_response 422
      expect(assigns(:product_entry).persisted?).to be(false)
    end

    it "returns json errors when a product entry can't be created" do
      sign_in inventory.owner

      post :create, params: { inventory_id: inventory.id }
      assert_response 422
      expect(json['errors'].values.flatten).to include("can't be blank")
    end

    it 'creates a record' do
      sign_in inventory.owner

      post :create, params: {
        inventory_id: inventory.id,
        general_inventory_question_attributes: {
          product_name: 'foo',
          data_type: [GeneralInventoryQuestion.product_types.first]
        },
        usage_question_attributes: {
          notes: 'notes'
        },
        technical_question_attributes: {
          hosting: TechnicalQuestion.hosting_options.first
        }
      }

      assert_response 201
    end
  end

  context '#update' do
    let(:product_entry) { inventory.product_entries.first }

    it 'requires logged in user' do
      sign_out :user

      put :update, params: { inventory_id: inventory.id, id: product_entry.id }
      assert_response :unauthorized
    end

    it "returns json errors when a product entry can't be updated" do
      sign_in inventory.owner

      put :update, params: {
        inventory_id: inventory.id,
        id: product_entry.id,
        general_inventory_question_attributes: {
          data_type: ['derp']
        }
      }

      expect(response).to have_http_status(422)
      expect(json['errors'].values.flatten).to include('derp is not permissible')
    end

    it 'updates a record' do
      sign_in inventory.owner

      put :update, params: {
        inventory_id: inventory.id,
        id: product_entry.id,
        usage_question_attributes: {
          notes: 'other notes'
        }
      }

      assert_response 200
      expect(product_entry.reload.usage_question.notes).to eq('other notes')
    end
  end
end
