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

    describe '#show' do
      it 'shows the invitation by the token' do
        get :show, token: 'expected_token'
        assert_response :success

        expect(json["token"]).to be_nil
        expect(json["email"]).to eq(@user.email)
      end
    end

    describe '#redeem' do
      it 'authorizes a user if they already have an account' do
        post :redeem, token: 'expected_token'
        expect(warden.authenticated?(:user)).to eq(true)
      end

      it 'gives a 401 when a user does exist' do
        @user.delete

        post :redeem, token: 'expected_token'
        expect(warden.authenticated?(:user)).to eq(false)

        assert_response :unauthorized
      end

      it 'allows an update for the users information' do
        post :redeem,
          token:      'expected_token',
          first_name: 'new',
          last_name:  'user',
          team_role:  'teacher',
          email:      'some_other@email.com'

        assert_response :success

        @user.reload

        expect(@user.first_name).to eq('new')
        expect(@user.last_name).to eq('user')
        expect(@user.team_role).to eq('teacher')
        expect(@user.email).to eq('some_other@email.com')
      end

      it 'returns errors if a users  fields cant be updated' do
        post :redeem,
          token:      'expected_token',
          password:   '123'

        assert_response 422
        expect(json["errors"]["password"]).not_to be_empty
      end

      it 'allows an update to set the users password' do
        post :redeem,
          token:      'expected_token',
          password:   'some_password'

        assert_response :success

        user = User.find_for_database_authentication(email: @user.email)
        expect(user.valid_password?('some_password')).to eq(true)
      end

      it 'deletes the invitation once it has been redeemed' do
        post :redeem,
          token:      'expected_token',
          password:   'some_password'

        expect(UserInvitation.find_by(token: 'expected_token')).to be_nil
      end
    end
  end

end
