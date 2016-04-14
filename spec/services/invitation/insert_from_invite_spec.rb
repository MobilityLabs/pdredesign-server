require 'spec_helper'

describe Invitation::InsertFromInvite do
  before { create_magic_assessments }
  let(:subject)    { Invitation::InsertFromInvite }
  let(:assessment) { @assessment_with_participants }

  def create_valid_invite(email = 'john_doe@gmail.com')
    UserInvitation.create!(assessment_id: assessment.id,
      first_name:    "john",
      last_name:     "doe",
      team_role:     "Finance",
      email:         email,
      role:          "facilitator")
  end

  def existing_user_invite
    UserInvitation.create!(assessment_id: assessment.id,
      first_name:    "john",
      last_name:     "doe",
      team_role:     "Finance",
      email:         @user.email)
  end

  describe '#execute' do
    context 'inviting network partner as participant' do
      let(:existing_user) { FactoryGirl.create(:user, :with_network_partner_role) }
      let(:invitation) { FactoryGirl.create(:user_invitation, :as_participant, assessment_id: assessment.id ,email: existing_user.email) }

      before(:each) do
        subject.new(invitation).execute
      end

      it 'overrides the role to be facilitator' do
        expect(assessment.facilitator?(existing_user)).to be true
      end
    end

    context 'inviting non network partner as participant' do
      let(:existing_user) { FactoryGirl.create(:user, :without_role) }
      let(:invitation) { FactoryGirl.create(:user_invitation, :as_participant, assessment_id: assessment.id ,email: existing_user.email) }

      before(:each) do
        subject.new(invitation).execute
      end

      it do
        expect(assessment.participant?(existing_user)).to be true
      end
    end
  end

  it 'creates a user account' do
    subject.new(create_valid_invite).execute
    expect(User.find_by(email: 'john_doe@gmail.com')).not_to be_nil
  end

  it 'creates a user account with mismatched case' do
    subject.new(create_valid_invite('John_Doe@gmail.com')).execute
    expect(User.find_by(email: 'john_doe@gmail.com')).not_to be_nil
  end

  it 'sets the correct district and team_role for a new user' do
    subject.new(create_valid_invite).execute

    user = User.find_by(email: 'john_doe@gmail.com')
    expect(user.district_ids).to eq([@district2.id])
    expect(user.team_role).to eq('Finance')
  end

  it 'appends the district_id and team_role to an already existing user' do
    @user.update(district_ids: [])
    expect(@user.district_ids).not_to include([@district2.id])
    subject.new(existing_user_invite).execute

    user = User.find_by(email: @user.email)
    expect(user.district_ids).to include(@district2.id)
    expect(user.team_role).to eq('Finance')
  end

  it 'does not create multiple district entries for existing user' do
    @user.update(district_ids: [@district2.id])

    subject.new(existing_user_invite).execute

    user = User.find_by(email: @user.email)
    expect(user.district_ids.count).to eq(1)

  end

  it 'updates the user_id after a user has been created' do
    subject.new(existing_user_invite).execute

    user = User.find_by(email: @user.email)
    expect(UserInvitation.find_by(user_id: user.id)).not_to be_nil
  end 

  it 'can safely create two invites' do
    subject.new(create_valid_invite).execute
    user = User.find_by(email: 'john_doe@gmail.com')

    Participant.find_by(user_id: user.id).delete
  end

  it 'creates a participant for an invite' do
    subject.new(create_valid_invite).execute
    user = User.find_by(email: 'john_doe@gmail.com')

    expect(Participant.find_by(user_id: user.id)).not_to be_nil
  end

  it 'creates a participant and set the specified role' do
    subject.new(create_valid_invite).execute
    expect(
      assessment.facilitator?(User.find_by(email: 'john_doe@gmail.com'))
    ).to eq(true)
  end
end
