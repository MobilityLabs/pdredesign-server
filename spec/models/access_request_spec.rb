# == Schema Information
#
# Table name: access_requests
#
#  id            :integer          not null, primary key
#  assessment_id :integer
#  user_id       :integer
#  roles         :string           default([]), is an Array
#  created_at    :datetime
#  updated_at    :datetime
#  token         :string(255)
#

require 'spec_helper'

describe AccessRequest do

  before { create_magic_assessments }
  let(:assessment) { @assessment_with_participants }
  let(:user_requesting_access) { FactoryGirl.create(:user) }

  context '#before_destroy' do
    it 'should flush_cached_version to the assessment when the access is granted' do
      access_request = Application.request_access_to_assessment(assessment: assessment, user: user_requesting_access, roles: ['facilitator'])

      expect(assessment).to receive(:flush_cached_version)
      access_request.destroy
    end
  end

  context '#after_create' do
    it 'should flush_cached_version to the assessment when the access is requested' do
      ar = AccessRequest.new({roles: ['facilitator'], token: SecureRandom.hex[0..9]})
      ar.user = user_requesting_access
      ar.assessment = assessment

      expect(assessment).to receive(:flush_cached_version)
      ar.save
    end
  end
end

