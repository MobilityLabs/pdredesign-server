require 'spec_helper'

describe ApplicationHelper do
  include ApplicationHelper

  describe '#scores_for_assessment' do
    before do
      @double = double("Assessment")  
      allow(@double).to receive(:scores_for_team_role).and_return(:team_role)
      allow(@double).to receive(:answered_scores).and_return(:answered_scores)
    end

    it 'returns the values from team roles' do
      expect(scores_for_assessment(@double, :some_role)).to eq(:team_role)
    end


    it 'returns the values from answered question' do
      expect(scores_for_assessment(@double)).to eq(:answered_scores)
      expect(scores_for_assessment(@double, nil)).to eq(:answered_scores)
    end
  end

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

    it 'returns nil when on exceptional behaviour' do
      expect(timestamp("stuff!")).to eq(nil)
    end
  end

end
