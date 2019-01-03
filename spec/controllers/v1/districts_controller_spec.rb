require 'spec_helper'

describe V1::DistrictsController do
  before :each do
    request.env["HTTP_ACCEPT"] = 'application/json'
  end
  render_views

  context '#search' do
    before do
      3.times  { |i| District.create(name: "some #{i}") }
      10.times { District.create(name: "other") }
      District.create(name: "other some")
    end

    it 'can search a districts name' do
      get :search, params: { query: 'some' }
      expect(json["results"].count).to eq(4)
    end

    it 'returns a limited set when blank' do
      get :search, params: { query: '' }
      expect(json["results"].count).to eq(10)
    end
  end

end
