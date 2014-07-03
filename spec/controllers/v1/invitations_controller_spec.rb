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

  context 'with invitation' do
    before do 
      @invitation = UserInvitation
        .create!(email: @user.email,
                 assessment: assessment,
                 token: 'expected_token')
    end

    it 'authorizes a user if they already have an account' do
      get :redeem, token: 'expected_token'
      expect(warden.authenticated?(:user)).to eq(true)
    end

    it 'gives a 401 when a user does exist' do
      @user.delete

      get :redeem, token: 'expected_token'
      expect(warden.authenticated?(:user)).to eq(false)

      assert_response :unauthorized
    end

    it 'allows an update for the users information' do
      get :redeem,
        token:      'expected_token',
        first_name: 'new',
        last_name:  'user',
        email:      'some_other@email.com'

      assert_response :success

      @user.reload

      expect(@user.first_name).to eq('new')
      expect(@user.last_name).to eq('user')
      expect(@user.email).to eq('some_other@email.com')
    end

    it 'allows an update to set the users password' do
      get :redeem,
        token:      'expected_token',
        password:   'some_password'

      assert_response :success

      user = User.find_for_database_authentication(email: @user.email)
      expect(user.valid_password?('some_password')).to eq(true)
    end
  end

end
