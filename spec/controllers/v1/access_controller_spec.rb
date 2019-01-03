require  'spec_helper'

describe V1::AccessController do
  render_views

  before(:each) do
    request.env['HTTP_ACCEPT'] = 'application/json'
  end

  describe 'POST #grant' do
    context 'when not authenticated' do
      before(:each) do
        sign_out :user
        post :grant, params: { token: 'stuff' }
      end

      it {
        is_expected.to respond_with :unauthorized
      }
    end

    context 'when not a facilitator on the assessment' do
      let(:access_request) {
        create(:access_request)
      }

      let(:non_facilitator) {
        create(:user, :with_district)
      }

      before(:each) do
        sign_in non_facilitator
        post :grant, params: { token: access_request.token }
      end

      it {
        is_expected.to respond_with :unauthorized
      }
    end

    context 'when a token is not found' do
      let(:assessment) {
        access_request.tool
      }

      let(:user) {
        assessment.user
      }

      let(:access_request) {
        create(:access_request)
      }

      before(:each) do
        sign_in user
        post :grant, params: { token: 'stuff' }
      end

      it {
        is_expected.to respond_with :missing
      }
    end

    context 'with user permission defined as facilitator' do
      let(:assessment) {
        access_request.tool
      }

      let(:user) {
        access_request.user
      }

      let(:facilitator) {
        assessment.facilitators.sample
      }

      let(:access_request) {
        create(:access_request)
      }

      before(:each) do
        sign_in facilitator
        post :grant, params: { token: access_request.token }
      end

      it {
        is_expected.to respond_with :success
      }

      it {
        expect(assessment.facilitator?(user)).to be true
      }
    end

    context 'with user permission defined as participant' do
      let(:assessment) {
        access_request.tool
      }

      let(:user) {
        access_request.user
      }

      let(:facilitator) {
        assessment.facilitators.sample
      }

      let(:access_request) {
        create(:access_request, :with_participant_role)
      }

      before(:each) do
        sign_in facilitator
        post :grant, params: { token: access_request.token }
      end

      it {
        is_expected.to respond_with :success
      }

      it  {
        expect(assessment.participant?(user)).to eq(true)
      }

      it {
        expect(Participant.find_by_user_id(user.id).invited_at).to_not be_nil
      }
    end
  end
end
