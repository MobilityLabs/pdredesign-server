require 'spec_helper'

describe V1::DistrictMessagesController do
  render_views

  before do
    request.env["HTTP_ACCEPT"] = 'application/json'
  end

  context '#create' do
    it 'can create a message record' do
      post :create, params: {
        name: 'test',
        address: 'some', 
        sender_name: 'name',
        sender_email: 'email@test.com'
      }

      assert_response :success
      record = DistrictMessage.find_by(address: 'some')
      expect(record.address).to eq('some')
      expect(record.sender_name).to eq('name')
      expect(record.sender_email).to eq('email@test.com')
    end

    it 'returns errors when message cant be created' do
      post :create, params: { name: 'test' }

      assert_response 422
      expect(json["errors"]).not_to be_empty
    end
  end

end
