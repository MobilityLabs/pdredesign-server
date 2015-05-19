require 'spec_helper'

describe Assessments::Permission do
  before { create_magic_assessments }

  let(:subject) { Assessments::Permission }

  let(:assessment) { @assessment_with_participants }
  let(:user) { Application.create_user }

  it 'available permissions' do
    expect(subject.available_permissions).to eq([:facilitator, :viewer, :partner, :participant])
  end

  context 'possible levels for a user' do
    
    before do
      participant = Participant.new
      participant.user = user
      participant.assessment = assessment
      participant.save!
    end

    it 'return the possible permissions level for a user' do
      @assessment_permission = Assessments::Permission.new(assessment)

      expect(@assessment_permission.possible_roles_permissions(user)).to eq([:facilitator, :viewer, :partner])
    end

  end

  context 'permission level' do

    before do
      @ra = Application.request_access_to_assessment(assessment: assessment, user: user, roles: ["facilitator"])
      @assessment_permission = Assessments::Permission.new(assessment)
    end

    it 'accept permission request' do
      @assessment_permission.accept_permission_requested(user)
      expect(assessment.facilitator?(user)).to eq(true)
    end

    it 'Add permission level to user' do
      @assessment_permission.add_level(user, "network_partner")
      expect(assessment.network_partner?(user)).to eq(true)
    end

    it 'should respond with the list of users requesting access' do
      expect(@assessment_permission.requested).to include(@ra)
    end

    it 'should return the permission level of a user' do
      @assessment_permission.accept_permission_requested(user)
      expect(@assessment_permission.user_level(user)).to eq(:facilitator)
    end

  end

end