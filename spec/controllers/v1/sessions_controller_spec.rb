require 'spec_helper'

describe V1::SessionsController do
  render_views

  context 'when an unknown user attempts to authenticate' do
    before(:each) do
      request.env['HTTP_ACCEPT'] = 'application/json'
      request.env['devise.mapping'] = Devise.mappings[:user]
      post :create, params: { email: 'someuser@user.com', password: 'somepassword' }
    end

    it 'denies them' do
      expect(response.status).to eq(401)
    end
  end

  context 'when a valid user attempts to authenticate' do
    let!(:preexisting_sample_user) {
      FactoryGirl.create(:user, :with_district, email: 'example@user.com', password: 'sup3r_s3cr3t')
    }

    context 'when the password supplied is incorrect' do
      before(:each) do
        request.env['HTTP_ACCEPT'] = 'application/json'
        request.env['devise.mapping'] = Devise.mappings[:user]
        post :create, params: { email: 'example@user.com', password: 'bad' }
      end

      it 'denies them' do
        expect(response.status).to eq(401)
      end
    end

    context 'when the password supplied is correct' do
      before(:each) do
        request.env['HTTP_ACCEPT'] = 'application/json'
        request.env['devise.mapping'] = Devise.mappings[:user]
        post :create, params: { email: 'example@user.com', password: 'sup3r_s3cr3t' }
      end

      it 'permits them' do
        expect(response).to be_success
      end

      it 'returns the user hash' do
        post :create, params: { email: 'example@user.com', password: 'sup3r_s3cr3t' }
        expect(json['user']['email']).to eq('example@user.com')
        expect(json['user']['password']).to be_nil
        expect(json['user']['first_name']).to eq('Example')
        expect(json['user']['last_name']).to eq('User')
      end
    end
  end
end
