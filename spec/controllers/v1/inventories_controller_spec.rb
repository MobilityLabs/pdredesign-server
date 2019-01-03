require 'spec_helper'
require 'faker'

describe V1::InventoriesController do
  render_views

  describe 'GET #index' do
    context 'when not authenticated' do

      before(:each) do
        get :index, as: :json
      end

      it {
        expect(response.status).to eq 401
      }
    end

    context 'when authenticated' do
      context 'when there are no records' do

        let(:user) {
          create(:user)
        }

        before(:each) do
          sign_in user
          get :index, as: :json
        end

        it 'pulls back an empty list' do
          expect(json.size).to eq 0
        end
      end

      context 'when there are records' do
        context 'when they belong to the current user' do

          let(:district) {
            create(:district)
          }

          let(:user) {
            create(:user, districts: [district])
          }

          let!(:inventory) {
            create(:inventory, owner: user, district: district)
          }

          before(:each) do
            sign_in user
            get :index, as: :json
          end

          it 'returns an array of size 1' do
            expect(json.size).to eq 1
          end

          it 'contains the single entry' do
            expect(json[0]['id']).to eq inventory.id
          end
        end

        context 'when they do not belong to the current user' do

          let(:user) {
            create(:user)
          }

          let(:other_user) {
            create(:user)
          }

          let!(:inventories) {
            create_list(:inventory, 5, owner: other_user)
          }

          before(:each) do
            sign_in user
            get :index, as: :json
          end
          it 'pulls back an empty list' do
            expect(json.size).to eq 0
          end
        end
      end
    end
  end

  describe 'GET #show' do
    context 'anonymous user' do
      context 'non existing inventory' do
        before(:each) do
          get :show, params: { id: 1 }, as: :json
        end

        it { expect(response).to have_http_status(:not_found) }
      end

      context 'existing inventory' do
        let(:inventory) { FactoryGirl.create(:inventory) }

        context 'by id' do
          before(:each) do
            get :show, params: { id: inventory.id }, as: :json
          end
          it { expect(response).to have_http_status(:unauthorized) }
        end

        context 'by share_token' do
          before(:each) do
            get :show, params: { id: inventory.share_token }, as: :json
          end
          it { expect(response).to have_http_status(:ok) }
        end
      end
    end

    context 'authenticated user' do
      context 'non existing inventory' do
        let(:user) { FactoryGirl.create(:user) }

        before(:each) do
          sign_in user
          get :show, params: { id: 1 }, as: :json
        end

        it { expect(response).to have_http_status(:not_found) }
      end

      context 'existing inventory' do
        context 'member user' do
          let(:inventory) { FactoryGirl.create(:inventory) }
          let(:user) { inventory.owner }

          before(:each) do
            sign_in user
            get :show, params: { id: inventory.id }, as: :json
          end

          it 'renders inventory identifier' do
            expect(json['id']).to eq inventory.id
          end

          it 'renders inventory name' do
            expect(json['name']).to eq inventory.name
          end
        end

        context 'non member user' do
          let(:user) { create(:user) }
          let(:other_user) { create(:user) }
          let(:inventory) { FactoryGirl.create(:inventory, owner: other_user) }

          before(:each) do
            sign_in user
            get :show, params: { id: inventory.id }, as: :json
          end

          it 'forbidden' do
            expect(response).to have_http_status(:forbidden)
          end
        end
      end
    end
  end

  describe 'POST #create' do
    context 'when not authenticated' do

      let(:district) {
        create(:district)
      }

      before(:each) do
        post :create, params: {
          inventory: {
            district: {id: district.id},
            name: 'I exist',
            deadline: 1.week.from_now.to_date.strftime('%m/%d/%y')
          }
        }, as: :json
      end

      it {
        expect(response.status).to eq 401
      }
    end


    context 'when authenticated' do
      context 'with a title that is too short' do
        let(:user) {
          create(:user, :with_district)
        }

        let(:district) {
          user.districts.first
        }

        before(:each) do
          sign_in user
          post :create, params: {
            inventory: {
              district: {id: district.id},
              name: '',
              deadline: 1.week.from_now.to_date.strftime('%m/%d/%y')
            }
          }, as: :json
        end

        it 'sends back a meaningful error message' do
          expect(json['errors']['name'][0]).to eq 'is too short (minimum is 1 character)'
        end

        it 'rejects the request' do
          expect(response.status).to eq 400
        end
      end

      context 'with a title that is too long' do
        let(:user) {
          create(:user, :with_district)
        }

        let(:district) {
          user.districts.first
        }

        before(:each) do
          sign_in user
          post :create, params: {
            inventory: {
              district: {id: district.id},
              name: Faker::Lorem.characters(256),
              deadline: 1.week.from_now.to_date.strftime('%m/%d/%y')
            }
          }, as: :json
        end

        it 'sends back a meaningful error message' do
          expect(json['errors']['name'][0]).to eq 'is too long (maximum is 255 characters)'
        end

        it 'rejects the request' do
          expect(response.status).to eq 400
        end
      end

      context 'with a valid title' do
        let(:user) {
          create(:user, :with_district)
        }

        let(:district) {
          user.districts.first
        }

        let(:deadline) {
          1.week.from_now.to_date
        }

        before(:each) do
          sign_in user
          post :create, params: {
            inventory: {
              district: {id: district.id},
              name: Faker::Lorem.characters(32),
              deadline: deadline
            }
          }, as: :json
        end

        it { expect(json['id']).to_not be_nil }
        it { expect(Time.parse(json['due_date'])).to eq deadline }
        it { expect(json['district_id']).to eq district.id }
        it { expect(json['owner_id']).to eq user.id }
        it { expect(json['name']).to_not be_nil }
        it { expect(json['created_at']).to_not be_nil }
        it { expect(json['updated_at']).to_not be_nil }
        it { expect(json['district_name']).to_not be_nil }

        it {
          expect(ToolMember.find_by(tool: assigns(:inventory),
                                    user: user,
                                    roles: [ToolMember.member_roles[:facilitator]])).to_not be_nil
        }


        it 'persists the entity' do
          expect(Inventory.all.size).to eq 1
        end
      end

      context 'with a missing deadline' do
        let(:user) {
          create(:user, :with_district)
        }

        let(:district) {
          user.districts.first
        }

        let(:deadline) {
          ''
        }

        before(:each) do
          sign_in user
          post :create, params: {
            inventory: {
              district: {id: district.id},
              name: Faker::Lorem.characters(32),
              deadline: deadline
            }
          }, as: :json
        end

        it 'rejects the request' do
          expect(response.status).to eq 400
        end

        it 'sends back a meaningful error message' do
          expect(json['errors']['deadline'][0]).to eq "can't be blank"
        end
      end

      context 'with a malformatted deadline string' do
        let(:user) {
          create(:user, :with_district)
        }

        let(:district) {
          user.districts.first
        }

        let(:deadline) {
          'foo this is broken bar'
        }

        before(:each) do
          sign_in user
          post :create, params: {
            inventory: {
              district: {id: district.id},
              name: Faker::Lorem.characters(32),
              deadline: deadline
            }
          }, as: :json
        end

        it 'rejects the request' do
          expect(response.status).to eq 400
        end

        xit 'sends back a meaningful error message' do
          expect(json['errors']['deadline'][0]).to eq 'must be in MM/DD/YYYY format'
        end

        it { expect(json['errors']['deadline'].length).to eq 1 }
      end

      context 'with a deadline in the past' do
        let(:user) {
          create(:user, :with_district)
        }

        let(:district) {
          user.districts.first
        }

        let(:deadline) {
          1.week.ago.to_date.strftime('%m/%d/%y')
        }

        before(:each) do
          sign_in user
          post :create, params: {
            inventory: {
              district: {id: district.id},
              name: Faker::Lorem.characters(32),
              deadline: deadline
            }
          }, as: :json
        end

        it 'rejects the request' do
          expect(response.status).to eq 400
        end

        xit 'sends back a meaningful error message' do
          expect(json['errors']['deadline'][0]).to eq 'cannot be in the past'
        end
      end
    end
  end
end
