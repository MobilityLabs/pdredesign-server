require 'spec_helper'

describe Link::Participant do
  before           { create_magic_assessments }
  before           { create_responses }
  let(:assessment) { @assessment_with_participants }
  let(:subject)    { Link::Participant }

  def links
    subject.new(assessment).execute
  end

  describe 'draft'  do
    it "returns nil if assesment is a draft" do
      allow(assessment).to receive(:status).and_return(:draft)

      expect(links).to  eq(nil)
    end
  end

  describe 'report' do
    it 'returns no report link when not fully_complete and consensus' do
      allow(assessment).to receive(:fully_complete?).and_return(false)
      allow(assessment).to receive(:status).and_return(:consensus)

      expect(links[:report]).to  eq(nil)
    end

    it 'returns report link when fully_complete and consensus' do
      allow(assessment).to receive(:fully_complete?).and_return(true)
      allow(assessment).to receive(:status).and_return(:consensus)

      expect(links[:report][:active]).to eq(true)
    end
  end

  describe 'action' do
    it 'returns a vote now when not consensus' do
      allow(assessment).to receive(:status).and_return(:assessment)

      expect(links[:action][:title]).to  eq('Complete Survey')
      expect(links[:action][:active]).to eq(true)
      expect(links[:action][:type]).to   eq(:response)
    end

    it 'returns a edit_response link when not fully_complete' do
      allow(assessment).to receive(:status).and_return(:consensus)
      allow(assessment).to receive(:fully_complete?).and_return(false)

      expect(links[:action][:title]).to  eq('Edit Survey')
    end

    it 'returns a consensus link when completed consensus' do
      allow(assessment).to receive(:status).and_return(:consensus)
      allow(assessment).to receive(:fully_complete?).and_return(true)

      expect(links[:action][:active]).to eq(true)
    end
  end
end

