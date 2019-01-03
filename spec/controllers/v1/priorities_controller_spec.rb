require 'spec_helper'

describe V1::PrioritiesController do
  render_views

  before(:each) do
    request.env["HTTP_ACCEPT"] = 'application/json'
  end

  describe '#create' do

    let(:assessment) {
      create(:assessment, :with_participants)
    }

    context 'when a user is unauthenticated' do
      before(:each) do
        sign_out :user
        post :create, params: {
          assessment_id: assessment.id,
          order: [1, 2, 3]
        }
      end

      it {
        is_expected.to respond_with :unauthorized
      }
    end

    context 'when the user is a facilitator' do
      let(:user) {
        assessment.facilitators.sample
      }

      before(:each) do
        sign_in user
        post :create, params: { assessment_id: assessment.id, order: [1, 2, 3] }
      end

      it {
        is_expected.to respond_with :success
      }
    end

    context 'when the user is a participant' do
      let(:user) {
        assessment.participants.sample.user
      }

      before(:each) do
        sign_in user
        post :create, params:{ assessment_id: assessment.id, order: [1, 2, 3] }
      end

      it {
        is_expected.to respond_with :forbidden
      }
    end

    context 'when the user is the owner' do
      context 'with a defined order' do
        let(:user) {
          assessment.user
        }

        before(:each) do
          sign_in user
          post :create, params: { assessment_id: assessment.id, order: [1, 2, 3] }
        end

        it {
          is_expected.to respond_with :success
        }

        it {
          expect(Priority.find_by(tool: assessment).order).to eq [1, 2, 3]
        }
      end

      context 'wtih an empty order' do
        let(:user) {
          assessment.user
        }

        before(:each) do
          sign_in user
          post :create, params: { assessment_id: assessment.id, order: nil }
        end

        it {
          is_expected.to respond_with :unprocessable_entity
        }
      end
    end
  end

  context '#index' do

    let(:assessment) {
      create(:assessment, :with_participants)
    }

    let(:user) {
      assessment.user
    }

    let(:fake_categories) {
      [{id: 1,
        name: 'Some cat2',
        average: 3.0},
       {id: 2,
        name: 'Some cat1',
        average: 3.0}
      ]
    }

    before(:each) do
      allow(controller).to receive(:categories)
                                .and_return(fake_categories)

      sign_in user
      get :index, params: { assessment_id: assessment.id }
    end

    it {
      is_expected.to respond_with :success
    }

    it {
      expect(assigns(:categories)).to eq fake_categories
    }

    it {
      expect(json.count).to eq 2
    }

    it {
      expect(json[0]["name"]).to eq 'Some cat2'
    }
    it {
      expect(json[0]["order"]).to eq 1
    }
    it {
      expect(json[0]["average"]).to be_within(0.01).of 3.0
    }
    it {
      expect(json[0]["diagnostic_min"]).to eq 2
    }
    it {
      expect(json[1]["name"]).to eq 'Some cat1'
    }
  end
end

