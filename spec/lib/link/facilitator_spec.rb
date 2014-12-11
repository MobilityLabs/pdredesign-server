require 'spec_helper'

describe Link::Facilitator do
  before           { create_magic_assessments }
  before           { create_responses }
  let(:assessment) { @assessment_with_participants }
  let(:subject)    { Link::Facilitator }

  before do
    allow(assessment).to receive(:status).and_return(:consensus)
  end

  def links
    subject.new(assessment).execute
  end

  it 'returns a dashboard link when an assessment is not a draft' do
    allow(assessment).to receive(:status).and_return(:assessment)

    expect(links[:dashboard][:title]).to  eq("View Dashboard")
    expect(links[:dashboard][:active]).to eq(true)
    expect(links[:dashboard][:type]).to   eq(:dashboard)


    allow(assessment).to receive(:status).and_return(:draft)

    expect(links[:dashboard]).to be_nil

    expect(links[:finish][:title]).to  eq("Finish & Assign")
    expect(links[:finish][:active]).to eq(true)
    expect(links[:finish][:type]).to   eq(:finish)
  end

  describe 'dashboard' do
    it 'returns a dashboard link' do
      expect(links[:dashboard][:title]).to  eq("View Dashboard")
      expect(links[:dashboard][:active]).to eq(true)
      expect(links[:dashboard][:type]).to   eq(:dashboard)
    end
  end

  describe 'consensus' do
    it 'returns a new consensus link when there isnt one' do
      allow(assessment).to receive(:status).and_return(:assessment)

      expect(links[:consensus][:title]).to  eq("Create Consensus")
      expect(links[:consensus][:active]).to eq(true)
      expect(links[:consensus][:type]).to   eq(:new_consensus)
    end

    it 'returns a consensus link when is a consensus' do
      allow(assessment).to receive(:status).and_return(:consensus)

      expect(links[:consensus][:type]).to   eq(:consensus)
    end

    it 'returns a no consensus link when is a draft' do
      allow(assessment).to receive(:status).and_return(:draft)

      expect(links[:consensus]).to  eq(nil)
    end
  end

  describe 'report' do
    it 'returns no report link when is assessment' do
      allow(assessment).to receive(:status).and_return(:assessment)

      expect(links[:report]).to  eq(nil)
    end

    it 'returns no report link when is draft' do
      allow(assessment).to receive(:status).and_return(:draft)

      expect(links[:report]).to  eq(nil)
    end

    it 'returns an active report link when consensus is fully complete' do
      allow(assessment).to receive(:status).and_return(:consensus)
      allow(assessment).to receive(:fully_complete?).and_return(true)

      expect(links[:report][:active]).to eq(true)
    end
  end

  describe 'execute' do
    it 'only returns finish when is draft' do
      allow(assessment).to receive(:status).and_return(:draft)
      expect(links.length).to eq(1)
      expect(links[:finish][:title]).to eq('Finish & Assign')
    end

    it 'returns dashboard, report, and consensus finish when is fully complete' do
      allow(assessment).to receive(:status).and_return(:consensus)
      allow(assessment).to receive(:fully_complete?).and_return(true)

      expect(links.length).to eq(3)
      expect(links[:dashboard][:title]).to eq('View Dashboard')
      expect(links[:report][:title]).to eq('View Report')
      expect(links[:consensus][:title]).to eq('Consensus')
    end

    it 'returns dashboard and consensus finish when consensus but not  fully complete' do
      allow(assessment).to receive(:status).and_return(:consensus)
      allow(assessment).to receive(:fully_complete?).and_return(false)

      expect(links.length).to eq(2)
      expect(links[:dashboard][:title]).to eq('View Dashboard')
      expect(links[:consensus][:title]).to eq('Consensus')
    end

    it 'returns response, consensus, and dashboard when assessment and is participant' do
      p = assessment.participants.last
      p.user_id = assessment.user.id
      assessment.participants.push(p)

      allow(assessment).to receive(:status).and_return(:assessment)

      expect(links.length).to eq(3)
      expect(links[:dashboard][:title]).to eq('View Dashboard')
      expect(links[:response][:title]).to eq('Complete Survey')
      expect(links[:consensus][:title]).to eq('Create Consensus')
    end

    it 'returns consensus and dashboard when assessment and is not participant' do
      allow(assessment).to receive(:status).and_return(:assessment)
      expect(links.length).to eq(2)
      expect(links[:dashboard][:title]).to eq('View Dashboard')
      expect(links[:consensus][:title]).to eq('Create Consensus')
    end
  end

end
