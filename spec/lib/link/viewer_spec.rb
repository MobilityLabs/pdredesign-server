require 'spec_helper'

describe Link::Viewer do
  before           { create_magic_assessments }
  before           { create_responses }
  let(:assessment) { @assessment_with_participants }
  let(:subject)    { Link::Viewer }

  def links
    subject.new(assessment, @user).execute
  end

  describe 'report' do
    it 'returns a disabled report link when not consensus' do
      allow(assessment).to receive(:status).and_return(:assessment)

      expect(links[:report][:title]).to  eq("View Report")
      expect(links[:report][:active]).to eq(false)
      expect(links[:report][:type]).to   eq(:report)
    end

    it 'returns an active report link when consensus' do
      allow(assessment).to receive(:status).and_return(:consensus)

      expect(links[:report][:active]).to eq(true)
    end
  end

  context 'access' do
    it 'returns a request access link' do
      expect(links[:access][:title]).to  eq("Request Access")
      expect(links[:access][:active]).to eq(true)
      expect(links[:access][:type]).to   eq(:request_access)
    end

    it 'returns pending when there is a pending request' do
      AccessRequest.create!(user_id: @user.id, assessment_id: assessment.id,
                            roles: [:viewer])

      expect(links[:access][:type]).to   eq(:pending)
    end
  end

end

