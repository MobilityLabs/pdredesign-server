require 'spec_helper'

describe V1::UserController do

  before do
    request.env["HTTP_ACCEPT"] = 'application/json'

    @user = Application::create_sample_user
    sign_in @user
  end

  render_views

  context '#request_reset' do
    before { sign_out :user }
    before { @user.update(email: 'some_user@gmail.com') }

    it 'sends the reset to a user' do
      post :request_reset, email: 'some_user@gmail.com'
      assert_response :success
    end

    it 'sends the reset to a user even if the email contains capital letters' do
      post :request_reset, email: 'SOME_User@GMail.com'
      assert_response :success
    end

    it 'sets the reset_password_token' do
      allow(controller).to receive(:hash).and_return('xyz')

      post :request_reset, email: 'some_user@gmail.com'
      expect(User.find(@user.id).reset_password_token).to eq('xyz')
    end

    it 'sets the reset_password_token' do
      @user.update(reset_password_sent_at: nil)

      post :request_reset, email: 'some_user@gmail.com'
      expect(User.find(@user.id).reset_password_sent_at).not_to be_nil
    end

    it 'queues up an email to be sent to user' do
      expect(PasswordResetNotificationWorker).to receive(:perform_async)
        .with(@user.id)

      post :request_reset, email: 'some_user@gmail.com'
    end

    it 'return error when the email does not exist' do
      post :request_reset, email: 'notexisting@user.com'
      assert_response 422
    end

  end

  context '#reset' do
    before { sign_out :user }

    it 'returns unauthorized if the token is not found' do
      @user.update(reset_password_token: 'expected_token')
      post :reset, token: 'other_token', password: 'xyz'

      assert_response :unauthorized
    end

    it 'requires the right token to reset password' do
      @user.update(reset_password_token: 'expected_token')

      post :reset, token: 'expected_token', password: 'xyz1235'
      assert_response :success

      expect(User.find(@user.id).valid_password?('xyz1235')).to eq(true)
    end

    it 'resets the password token and sent_at' do
      @user.update(reset_password_token: 'expected_token',
                   reset_password_sent_at: Time.now)

      post :reset, token: 'expected_token', password: 'xyz1235'
      assert_response :success

      user = User.find(@user.id)
      expect(user.reset_password_token).to eq(nil)
      expect(user.reset_password_sent_at).to eq(nil)
      expect(subject.current_user).to eq(user)
    end

    it 'returns errors when user cant be updated' do
      @user.update(reset_password_token: 'expected_token')

      post :reset, token: 'expected_token', password: 'xyz'
      assert_response 422

      expect(json["errors"]["password"]).not_to eq(nil)
    end


  end

  context '#create' do
    before { @district  = District.create! }
    before { @district2 = District.create! }
    before { sign_out :user }

    def post_create_user(options = {})
      opts = { first_name: 'kim',
               email: 'kim@gov.nk',
               last_name: 'jong',
               district_ids: @district.id,
               password: 'some_password',
               team_role: 'leader'}

      post :create, opts.merge(options)
    end


    it 'can create a user' do
      post_create_user
      kim = User.find_by(email: 'kim@gov.nk')

      assert_response :success
      expect(kim[:first_name]).to eq('kim')
      expect(kim[:last_name]).to eq('jong')
      expect(kim[:team_role]).to eq('leader')

      expect(kim.district_ids).to eq([@district.id])
      expect(kim.valid_password?('some_password')).to eq(true)
    end

    it 'sets default user to a member' do
      post_create_user

      kim = User.find_by(email: 'kim@gov.nk')
      expect(kim[:role]).to eq('member')
    end

    it 'returns errors' do
      post_create_user(email: 'some_invalid-email!!1one') 

      assert_response 422
      expect(json["errors"]).not_to be_nil
    end


    it 'sets the user to the role provided' do
      post_create_user(role: :other)

      kim = User.find_by(email: 'kim@gov.nk')
      expect(kim[:role]).to eq('other')
    end

    it 'sends the signup notification to the user' do
      post_create_user
      expect(SignupNotificationWorker.jobs.count).to eq(1)
    end

    it 'it can take multiple districts_ids' do
      post_create_user(district_ids: "#{@district.id}, #{@district2.id}")

      kim = User.find_by(email: 'kim@gov.nk')
      expect(kim.districts.count).to eq(2)
    end

    it 'can signup with empty districts' do
      post_create_user(district_ids: nil)
      assert_response :success

      kim = User.find_by(email: 'kim@gov.nk')
      expect(kim.districts.count).to eq(0)
    end

    it 'it can take multiple organization_ids' do
      org1 = Organization.create!(name: "org1")
      org2 = Organization.create!(name: "org2")

      post_create_user(organization_ids: "#{org1.id}, #{org2.id}")

      kim = User.find_by(email: 'kim@gov.nk')
      expect(kim.organizations.count).to eq(2)
    end
  end

  context '#show' do
    it 'requires a user to be logged in' do
      sign_out :user
      get :show
      assert_response :unauthorized
    end

    it 'returns the current user' do
      get :show
      expect(json["first_name"]).to eq('Example')
    end
  end

  context '#update' do
    it 'updates a users fields' do
      put :update, { first_name: 'updated', last_name: 'user' }

      expect(json["first_name"]).to eq('updated')
    end

    it 'can take multiple districts' do
      district  = District.create!
      district2 = District.create!

      put :update, { district_ids: "#{district.id}, #{district2.id}"}
      expect(json["district_ids"].count).to eq(2)
    end

    it 'returns errors on ActiveRecord failure' do
      put :update, { email: 'asdfasdf' }

      expect(response.status).to eq(422)
      expect(json["errors"]).to_not be_nil
    end

    context 'extract_ids' do
      it 'should not reset the district_ids' do
        district = District.create!
        @user.update(districts: [district])

        put :update, {email: 'some@user.com'} 

        @user.reload
        expect(@user.district_ids).to eq([district.id])
      end

      it 'should not reset the organization_ids' do
        org = Organization.create!(name: 'test')
        @user.update(organizations: [org])

        put :update, {email: 'some@user.com'} 

        @user.reload
        expect(@user.organization_ids).to eq([org.id])
      end

      it 'resets :district_ids when a key is explicitly set to nil' do
        district = District.create!
        @user.update(districts: [district])

        put :update, {email: 'some@user.com', district_ids: nil} 

        @user.reload
        expect(@user.district_ids).to be_empty
      end

      it 'resets :organization_ids when a key is explicitly set to nil' do
        org = Organization.create!(name: 'test')
        @user.update(organizations: [org])

        put :update, {email: 'some@user.com', organization_ids: nil} 

        @user.reload
        expect(@user.organization_ids).to be_empty
      end
    end
  end
end
