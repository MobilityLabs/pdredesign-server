require 'spec_helper'

describe V1::OrganizationsController do
  render_views

  before :each do
    request.env['HTTP_ACCEPT'] = 'application/json'
  end

  let(:user) { FactoryGirl.create(:user, :with_district, :with_network_partner_role) }

  before do
    sign_in user
  end 

  def create_org
    @cat = Category.create!(name: 'some cat')
    @org = Organization.create!(name: 'example org', category_ids: [@cat.id]) 
  end

  describe '#upload' do
    before { create_org }

    it 'sends the file to carrierwave' do
      double = double(Organization).as_null_object
      file   = fixture_file_upload('files/logo.png', 'image/png')
      allow(controller).to receive(:find_organization).and_return(double)

      expect(double).to receive(:update).with(logo: anything)
      post :upload, params: { upload: file, organization_id: @org.id }
    end

    it 'does not allow non-networkpartner to upload' do
      user.update(role: :district_member)

      file   = fixture_file_upload('files/logo.png', 'image/png')

      post :upload, params: { file: file, organization_id: @org.id }
      assert_response 403 
    end
  end

  describe '#create' do
    it 'creates an organization' do
      post :create, params: { name: 'Org LLC', category_ids: '1,2,3' }

      assert_response :success
      expect(Organization.where(name: 'Org LLC').count).to eq(1)
    end

    it 'assigns the correct categories' do
      categories = 3.times.map { Category.create! }

      post :create, params: { name: 'Org LLC', category_ids: categories.map(&:id) }

      org = Organization.find_by(name: 'Org LLC')
      expect(org.categories.count).to eq(3)

      categories.each do |category|
        expect(org.categories.include?(category)).to eq(true) 
      end
    end

    it 'returns errors for an invalid org' do
      post :create
      expect(json["errors"]).not_to be_empty
    end

    it 'anyone can create an org' do
      sign_out :user

      post :create, params: { name: 'Org LLC' }
      assert_response :success

      org = Organization.find_by(name: 'Org LLC')
      expect(org).not_to be_nil
    end
  end

  context 'with data ' do
    before { create_org }

    describe '#update' do
      it 'updates an organization' do
        post :update, params: { id: @org.id, name: 'new_name' }

        expect(Organization.find(@org.id).name).to eq('new_name')
      end

      it 'returns errors for an invalid update' do
        post :update, params: { id: @org.id, name: nil, category_ids: '1' }

        assert_response 422
        expect(json["errors"]).not_to be_empty
      end
    end

    describe '#search' do
      it 'doesnt require a login user to do a search' do
        sign_out :user

        get :search, params: { query: 'name' }
        assert_response :success
      end

      it 'returns a searched org' do
        3.times { |i| Organization.create(name: "name #{i}") }

        Organization.create(name: "other") 

        get :search, params: { query: 'name' }
        expect(assigns(:results).count).to eq(3)
      end
    end

    describe '#show' do
      it 'finds the correct organization' do
        get :show, params: { id: @org.id }
        expect(assigns(:organization)).to eq(@org)
      end

      it 'does not require a user' do
        sign_out user

        get :show, params: { id: @org.id }
        expect(assigns(:organization)).to eq(@org)
      end
    end

  end
end
