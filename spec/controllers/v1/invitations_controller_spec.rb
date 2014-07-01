require 'spec_helper'

describe V1::InvitationsController do
  before { create_magic_assessments }
  before :each do
    request.env["HTTP_ACCEPT"] = 'application/json'
  end

  let(:assessment) { @assessment_with_participants }
  render_views

 
  it 'returns 404 when an invitation is not found' do
    get :redeem, token: 'xyz'
    assert_response 404
  end

  it 'authorizes a user if they already have an account' do
    invitation = UserInvitation
      .create!(email: @user.email, assessment: assessment)

    invitation.update(token: 'expected_token')

    get :redeem, token: 'expected_token'
    expect(warden.authenticated?(:user)).to eq(true)
  end

  it 'gives a 401 when a user does not already exist' do
    invitation = UserInvitation
      .create!(email: @user.email, assessment: assessment)

    @user.delete

    invitation.update(token: 'expected_token')

    get :redeem, token: 'expected_token'
    expect(warden.authenticated?(:user)).to eq(false)

    assert_response :unauthorized
  end
end
