require 'spec_helper'

describe V1::ProspectiveUsersController do
  before :each do
    request.env["HTTP_ACCEPT"] = 'application/json'
  end
  render_views

  context '#create' do
    it 'can create a prospective user' do
      post :create, params: { email: 'some_email@gmail.com', ip_address: '000.000.000.00' }
      expect(response).to be_success
    end

    it 'can create a prospective_user record' do
      expect(ProspectiveUser).to receive(:create)
        .with(hash_including(email: 'some_email@google.com', ip_address: '000.000.000.00'))
        .and_call_original

      post :create, params: { email: 'some_email@google.com', ip_address: '000.000.000.00' }
    end

    it 'returns errors on invalid response' do
      post :create, params: { email: '!@#!@#some_email@google.com', ip_address: '000.000.000.00' }
      expect(response.status).to eq(422)
      expect(json["errors"]["email"].first).to eq("is invalid")
    end

  end
end
