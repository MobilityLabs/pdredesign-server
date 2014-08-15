require 'spec_helper'

describe ApplicationHelper do
  include ApplicationHelper

  describe '.fetch_districts' do
    it 'returns all districts with a given id' do
      districts = 10.times.map { District.create! }  
      fetched   = fetch_districts([districts[0].id, districts[5].id])
      expect(fetched.count).to eq(2)
    end
  end

  describe '.timestamp' do
    it 'returns a timestamp' do
      time = Time.at(1259222400) 
      expect(timestamp(time)).to eq("1259222400")
    end

    it 'returns nil when date_time is falsy' do
      expect(timestamp(nil)).to eq(nil)
    end
  end

end
