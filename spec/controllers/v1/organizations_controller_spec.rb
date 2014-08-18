require 'spec_helper'

describe V1::OrganizationsController do
  render_views

  before :each do
    request.env["HTTP_ACCEPT"] = 'application/json'
  end

  before do
    @district = District.create!
    @user     = Application::create_sample_user(districts: [@district], role: :network_partner)

    sign_in @user
  end 

  def create_org
    @cat = Category.create!(name: 'some cat')
    @org = Organization.create!(name: 'example org', category_ids: [@cat.id]) 
  end

  describe '#create' do
    it 'creates an organization' do
      post :create, name: 'Org LLC', category_ids: '1,2,3'

      assert_response :success
      expect(Organization.where(name: 'Org LLC').count).to eq(1)
    end

    it 'assigns the correct categories' do
      categories = 3.times.map { Category.create! }

      post :create, name: 'Org LLC', category_ids: categories.map(&:id)

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

    it 'requires a user to create an org' do
      sign_out :user

      post :create
      assert_response :unauthorized
    end

    it 'only allows :network_partners to create an org' do
      @user.update(role: :district_member)

      post :create
      assert_response :forbidden
    end
  end

  context 'with data ' do
    before { create_org }

    describe '#update' do
      it 'updates an organization' do
        post :update, id: @org.id, name: 'new_name'

        expect(Organization.find(@org.id).name).to eq('new_name')
      end

      it 'returns errors for an invalid update' do
        post :update, id: @org.id, name: nil, category_ids: '1'

        assert_response 422
        expect(json["errors"]).not_to be_empty
      end
    end

    describe '#search' do
      it 'returns a searched org' do
        3.times { |i| Organization.create(name: "name #{i}") }

        Organization.create(name: "other") 

        get :search, query: 'name'
        expect(assigns(:results).count).to eq(3)
      end
    end

    describe '#show' do
      it 'finds the correct organization' do
        get :show, id: @org.id
        expect(assigns(:organization)).to eq(@org)
      end
    end

  end
end
