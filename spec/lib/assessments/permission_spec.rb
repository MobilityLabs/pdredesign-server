require 'spec_helper'

describe Assessments::Permission do
  before { create_magic_assessments }

  let(:subject) { Assessments::Permission }

  let(:assessment) { @assessment_with_participants }
  let(:user) { Application.create_user }

  it 'available permissions' do
    expect(subject.available_permissions).to eq([:facilitator, :viewer, :participant])
  end

  context 'request access to assessment' do
    
    it 'should create the access request object using request_access method' do
      Assessments::Permission.request_access(
        user: user, 
        roles: "facilitator",
        assessment_id: assessment.id)

      expect(
        AccessRequest.find_by(assessment_id: assessment.id, user_id: user.id)
      ).not_to be_nil
    end

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

      expect(@assessment_permission.possible_roles_permissions(user)).to eq([:facilitator, :viewer])
    end

  end

  context 'permission level' do

    before do
      @ra = Application.request_access_to_assessment(assessment: assessment, user: user, roles: ["facilitator"])
      @assessment_permission = Assessments::Permission.new(assessment)
    end

    it 'accept permission request' do
      expect(AccessGrantedNotificationWorker).to receive(:perform_async)
      
      @assessment_permission.accept_permission_requested(user)

      expect(assessment.facilitator?(user)).to eq(true)
    end

    it 'accept a participant request' do
      new_user = Application.create_user
      Application.request_access_to_assessment(
        assessment: assessment, user: new_user, roles: ["participant"])

      @assessment_permission.accept_permission_requested(new_user)
      expect(assessment.participant?(new_user)).to eq(true)
    end

    it 'Add permission level to user' do
      @assessment_permission.add_level(user, "network_partner")
      expect(assessment.network_partner?(user)).to eq(true)
    end

    it 'should respond with the list of users requesting access' do
      expect(@assessment_permission.requested).to include(@ra)
    end

    it 'should return the permission level of a user: #get_level method' do
      @assessment_permission.accept_permission_requested(user)
      expect(@assessment_permission.get_level(user)).to eq(:facilitator)
    end

    it 'should update the permission level' do
      assessment.facilitators << @facilitator
      @assessment_permission.update_level(@facilitator, 'viewer')

      expect(assessment.facilitator?(@facilitator)).to eq(false)
      expect(@assessment_permission.get_level(@facilitator)).to eq(:viewer)
    end

    it 'should update only when the new level is different' do
      assessment.facilitators << @facilitator

      expect(AccessGrantedNotificationWorker).not_to receive(:perform_async)

      @assessment_permission.update_level(@facilitator, 'facilitator')

      expect(assessment.facilitator?(@facilitator)).to eq(true)
    end

    it 'owner shold not be updated' do
      owner = assessment.user
      
      @assessment_permission.update_level(assessment.user, 'viewer')

      expect(assessment.owner?(owner)).to eq(true)
      expect(assessment.viewer?(owner)).to eq(false)
    end
  end

  context 'deny permission request' do
    before do
      Application.request_access_to_assessment(assessment: assessment, user: user, roles: ["facilitator"])
      @assessment_permission = Assessments::Permission.new(assessment)
    end

    it 'should deny permission by deleting the request' do
      @assessment_permission.deny(user)

      expect(
        @assessment_permission.get_access_request(user)
      ).to eq(nil)
    end
  end

  context 'participants' do
    it 'do not send notification for permission granted when is participant' do
      Application.request_access_to_assessment(assessment: assessment, user: user, roles: ["participant"])
      expect(AccessGrantedNotificationWorker).not_to receive(:perform_async)

      assessment_permission = Assessments::Permission.new(assessment)
      assessment_permission.accept_permission_requested(user)
    end
  end

  context 'notification emails' do
    before do
      @ra = Application.request_access_to_assessment(assessment: assessment, user: user, roles: ["facilitator"])
      @assessment_permission = Assessments::Permission.new(assessment)
      expect(AccessGrantedNotificationWorker).to receive(:perform_async)
    end

    it 'Notify the user by email' do
      @assessment_permission.accept_permission_requested(user)
    end

    it 'Send an email when the permission level is added' do
      @assessment_permission.add_level(user, "facilitator")
    end
  end

end