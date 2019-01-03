require 'spec_helper'

describe V1::AssessmentsPermissionsController do
  render_views

  before(:each) do
    request.env['HTTP_ACCEPT'] = 'application/json'
  end

  let(:assessment) {
    create(:assessment, :with_participants)
  }

  describe 'GET #index' do
    context 'when authorized' do
      let(:user) {
        assessment.user
      }

      context 'when an access request is present' do
        let!(:access_request) {
          create(:access_request, tool: assessment, user: user, roles: ['facilitator'])
        }

        before(:each) do
          sign_in user
          get :index, params: { assessment_id: assessment.id }
        end

        it {
          expect(json.first['requested_permission_level']).to_not be_nil
        }
      end

      context 'when an access request is not present' do
        before(:each) do
          sign_in user
          get :index, params: { assessment_id: assessment.id }
        end

        it {
          is_expected.to respond_with :success
        }

        it {
          expect(json).to be_empty
        }
      end
    end

    context 'when unauthorized' do
      before(:each) do
        sign_out :user
        get :index, params: { assessment_id: assessment.id }
      end

      it {
        is_expected.to respond_with :unauthorized
      }
    end
  end

  describe 'GET #all_users' do
    context 'when authorized' do
      let(:user) {
        assessment.user
      }

      before(:each) do
        sign_in user
        get :all_users, params: { assessment_id: assessment.id }
      end

      it {
        is_expected.to respond_with :success
      }

      it {
        expect(json.first['permission_level']).to be_nil
      }

      it 'returns all associated users' do
        expected_user_list = (assessment.users + [assessment.user] + assessment.facilitators).map(&:id)
        actual_user_list = json.map { |json_obj| json_obj['id'] }
        expect(actual_user_list.to_set.intersect?(expected_user_list.to_set)).to be true
      end
    end

    context 'when unauthorized' do
      before(:each) do
        sign_out :user
        get :all_users, params: { assessment_id: assessment.id }
      end

      it {
        is_expected.to respond_with :unauthorized
      }
    end
  end

  describe 'GET #show' do
    context 'when authenticated' do
      context 'when not authorized' do
        let(:user) {
          create(:user, :with_district)
        }

        let(:access_request) {
          create(:access_request)
        }

        before(:each) do
          sign_in user
          get :show, params: { assessment_id: assessment.id, id: access_request.id }
        end

        it {
          is_expected.to respond_with :forbidden
        }
      end

      context 'when an access request is present' do
        let(:access_request) {
          create(:access_request, tool: assessment, user: user, roles: ['facilitator'])
        }

        let(:user) {
          create(:user, :with_district)
        }

        let(:facilitator) {
          assessment.user
        }

        before(:each) do
          sign_in facilitator
          get :show, params: { assessment_id: assessment.id, id: access_request.id, user: user, email: access_request.user.email }
        end

        it {
          is_expected.to respond_with :success
        }

        it {
          expect(json['requested_permission_level']).to_not be_nil
        }
      end

      context 'when an access request is not present' do

        let(:facilitator) {
          assessment.user
        }

        before(:each) do
          sign_in facilitator
          get :show, params: { assessment_id: assessment.id, id: 0 }
        end

        it {
          is_expected.to respond_with :missing
        }
      end
    end

    context 'when not authenticated' do
      let(:access_request) {
        create(:access_request)
      }

      before(:each) do
        sign_out :user
        get :show, params: { assessment_id: assessment.id, id: access_request.id }
      end

      it {
        is_expected.to respond_with :unauthorized
      }
    end
  end

  describe 'PUT #update' do
    context 'when authenticated' do
      context 'when not authorized' do
        let(:user) {
          create(:user, :with_district)
        }

        before(:each) do
          sign_in user
          put :update, params: { assessment_id: assessment.id, id: 0 }
        end

        it {
          is_expected.to respond_with :forbidden
        }
      end

      context 'when changing the role from network partner to facilitator' do
        let(:network_partner) {
          create(:user, :with_network_partner_role)
        }

        let(:assessment_with_network_partner) {
          assessment = create(:assessment, :with_participants)
          assessment.facilitators << [network_partner]
          assessment
        }

        before(:each) do
          sign_in network_partner
          put :update, params: {
            assessment_id: assessment_with_network_partner.id,
            id: network_partner.id,
            permissions: [{
              level: 'facilitator',
              email: network_partner.email
            }]
          }
        end

        it {
          is_expected.to respond_with :success
        }

        it {
          expect(assessment_with_network_partner.facilitator?(network_partner)).to be true
        }

        it {
          expect(assessment_with_network_partner.network_partner?(network_partner)).to be false
        }
      end

      context 'when changing the role from participant to network partner' do
        let(:participant) {
          assessment.participants.sample.user
        }

        let(:user) {
          assessment.user
        }

        before(:each) do
          sign_in user
          put :update, params: {
            assessment_id: assessment.id, id: participant.id,
            permissions: [{
              level: 'network_partner',
              email: participant.email
            }]
          }
        end

        it {
          is_expected.to respond_with :success
        }

        it {
          expect(assessment.facilitator?(participant)).to be false
        }

        it {
          expect(assessment.network_partner?(participant)).to be true
        }
      end

      context 'when changing the role from participant to facilitator' do
        let(:participant) {
          assessment.participants.sample.user
        }

        let(:user) {
          assessment.user
        }

        before(:each) do
          sign_in user
          put :update, params: {
            assessment_id: assessment.id,
            id: participant.id,
            permissions: [{
              level: 'facilitator',
              email: participant.email
            }]
          }
        end

        it {
          is_expected.to respond_with :success
        }

        it {
          expect(assessment.facilitator?(participant)).to be true
        }

        it {
          expect(assessment.participant?(participant)).to be true
        }
      end

      context 'when changing the role from facilitator to network partner' do
        let(:facilitator) {
          assessment.facilitators.sample
        }

        let(:user) {
          assessment.user
        }

        before(:each) do
          sign_in user
          put :update, params: {
            assessment_id: assessment.id,
            id: facilitator.id,
            permissions: [{
              level: 'network_partner',
              email: facilitator.email
            }]
          }
        end

        it {
          is_expected.to respond_with :success
        }

        it {
          expect(assessment.facilitator?(facilitator)).to be false
        }

        it {
          expect(assessment.network_partner?(facilitator)).to be true
        }
      end
    end

    context 'when changing the role from facilitator to participant' do
      let(:facilitator) {
        assessment.facilitators.sample
      }

      let(:user) {
        assessment.user
      }

      before(:each) do
        sign_in user
        put :update, params: {
          assessment_id: assessment.id,
          id: facilitator.id,
          permissions: [{
            level: 'participant',
            email: facilitator.email
          }]
        }
      end

      it {
        is_expected.to respond_with :success
      }

      it {
        expect(assessment.facilitator?(facilitator)).to be false
      }

      it {
        expect(assessment.participant?(facilitator)).to be false
      }

      it {
        expect(assessment.owner?(facilitator)).to be false
      }

      it {
        expect(assessment.network_partner?(facilitator)).to be false
      }

      it {
        expect(assessment.viewer?(facilitator)).to be false
      }
    end

    context 'when changing the role from network partner to participant' do
      let(:network_partner) {
        u = create(:user, :with_network_partner_role)
        assessment.network_partners << u
        u
      }

      let(:user) {
        assessment.user
      }

      before(:each) do
        sign_in user
        put :update, params: {
          assessment_id: assessment.id, id: network_partner.id,
          permissions: [{
            level: 'participant',
            email: network_partner.email
          }]
        }
      end

      it {
        is_expected.to respond_with :success
      }

      it {
        expect(assessment.facilitator?(network_partner)).to be true
      }

      it {
        expect(assessment.participant?(network_partner)).to be false
      }

      it {
        expect(assessment.owner?(network_partner)).to be false
      }

      it {
        expect(assessment.network_partner?(network_partner)).to be false
      }

      it {
        expect(assessment.viewer?(network_partner)).to be false
      }
    end

    context 'when changing the role from network partner to facilitator' do
      let(:network_partner) {
        u = create(:user, :with_network_partner_role)
        assessment.network_partners << u
        u
      }

      let(:user) {
        assessment.user
      }

      before(:each) do
        sign_in user
        put :update, params: {
          assessment_id: assessment.id,
          id: network_partner.id,
          permissions: [{
            level: 'facilitator',
            email: network_partner.email
          }]
        }
      end

      it {
        is_expected.to respond_with :success
      }

      it {
        expect(assessment.facilitator?(network_partner)).to be true
      }

      it {
        expect(assessment.participant?(network_partner)).to be false
      }

      it {
        expect(assessment.owner?(network_partner)).to be false
      }

      it {
        expect(assessment.network_partner?(network_partner)).to be false
      }

      it {
        expect(assessment.viewer?(network_partner)).to be false
      }
    end

    context 'when changing the current user role' do
      let(:user) {
        assessment.user
      }

      before(:each) do
        sign_in user
        put :update, params: {
          assessment_id: assessment.id,
          id: user.id,
          permissions: [{
            level: 'network_partner',
            email: user.email
          }]
        }
      end

      it {
        is_expected.to respond_with :success
      }

      it {
        expect(assessment.owner?(user)).to be true
      }

      it {
        expect(assessment.network_partner?(user)).to be false
      }
    end

    context 'when no permissions field is provided' do
      let(:participant) {
        assessment.participants.sample.user
      }

      let(:user) {
        assessment.user
      }

      before(:each) do
        sign_in user
        put :update, params: { assessment_id: assessment.id, id: participant.id }
      end

      it {
        is_expected.to respond_with :success
      }

      it {
        expect(assessment.participant?(participant)).to be true
      }
    end

    context 'when not authenticated' do

      before(:each) do
        sign_out :user
        put :update, params: { assessment_id: assessment.id, id: 1 }
      end

      it {
        is_expected.to respond_with :unauthorized
      }
    end
  end

  describe 'PUT #deny' do

    let(:user) {
      create(:user, :with_district)
    }

    context 'when unauthenticated' do
      before(:each) do
        sign_out :user
        put :deny, params: { assessment_id: assessment.id, id: 0, email: user.email }
      end

      it {
        is_expected.to respond_with :unauthorized
      }
    end

    context 'when authenticated' do
      context 'when authorized to update permissions' do
        let(:facilitator) {
          assessment.user
        }

        let(:access_request) {
          create(:access_request, tool: assessment, user: user, roles: ['facilitator'])
        }

        let(:assessment_permission) {
          Assessments::Permission.new(assessment)
        }

        before(:each) do
          sign_in facilitator
          put :deny, params: { assessment_id: assessment.id, id: access_request.id, email: user.email }
        end

        it {
          is_expected.to respond_with :success
        }

        it {
          expect(assessment.facilitator?(user)).to be false
        }

        it {
          expect(assessment_permission.get_access_request(user)).to be_nil
        }
      end
    end

    context 'when unauthorized to update permissions' do
      let(:participant) {
        assessment.participants.sample.user
      }

      let(:access_request) {
        create(:access_request, tool: assessment, user: user, roles: ['facilitator'])
      }

      before(:each) do
        sign_in participant
        put :deny, params: { assessment_id: assessment.id, id: access_request.id, email: user.email }
      end

      it {
        is_expected.to respond_with :forbidden
      }
    end
  end

  describe 'PUT #accept' do
    let(:user) {
      create(:user, :with_district)
    }

    context 'when unauthenticated' do
      before(:each) do
        sign_out :user
        put :accept, params: { assessment_id: assessment.id, id: 0, email: user.email }
      end

      it {
        is_expected.to respond_with :unauthorized
      }
    end

    context 'when authenticated' do
      context 'when authorized' do
        let(:facilitator) {
          assessment.facilitators.sample
        }

        let(:access_request) {
          create(:access_request, tool: assessment, user: user, roles: ['facilitator'])
        }

        before(:each) do
          sign_in facilitator
          put :accept, params: { assessment_id: assessment.id, id: access_request.id, email: user.email }
        end

        it {
          is_expected.to respond_with :success
        }

        it {
          expect(assessment.facilitator?(user)).to be true
        }
      end

      context 'when unauthorized' do
        let(:participant) {
          assessment.participants.sample.user
        }

        let(:access_request) {
          create(:access_request, tool: assessment, user: user, roles: ['facilitator'])
        }

        before(:each) do
          sign_in participant
          put :accept, params: { assessment_id: assessment.id, id: access_request.id, email: user.email }
        end

        it {
          is_expected.to respond_with :forbidden
        }
      end
    end
  end

  describe 'GET #current_level' do
    context 'when unauthenticated' do
      before(:each) do
        sign_out :user
        get :current_level, params: { assessment_id: assessment.id }
      end

      it {
        is_expected.to respond_with :unauthorized
      }
    end

    context 'when authenticated' do
      context 'when the user is an owner' do
        let(:user) {
          assessment.user
        }

        before(:each) do
          sign_in user
          get :current_level, params: { assessment_id: assessment.id }
        end

        it {
          expect(json['permission_level']).to eq 'facilitator'
        }
      end

      context 'when the user is a facilitator' do
        let(:user) {
          assessment.facilitators.sample
        }

        before(:each) do
          sign_in user
          get :current_level, params: { assessment_id: assessment.id }
        end

        it {
          expect(json['permission_level']).to eq 'facilitator'
        }
      end

      context 'when the user is a participant' do
        let(:user) {
          assessment.participants.sample.user
        }

        before(:each) do
          sign_in user
          get :current_level, params: { assessment_id: assessment.id }
        end

        it {
          expect(json['permission_level']).to eq 'participant'
        }
      end

      context 'when the user is a network partner' do
        let(:user) {
          u = create(:user, :with_network_partner_role)
          assessment.network_partners << u
          u
        }

        before(:each) do
          sign_in user
          get :current_level, params: { assessment_id: assessment.id }
        end

        it {
          is_expected.to respond_with :forbidden
        }
      end
    end
  end
end
