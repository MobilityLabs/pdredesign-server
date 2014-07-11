require 'spec_helper'

describe Invitation::InsertFromInvite do
  before { create_magic_assessments }
  let(:subject)    { Invitation::InsertFromInvite }
  let(:assessment) { @assessment_with_participants }

  def create_valid_invite
    UserInvitation.create!(assessment_id: assessment.id,
      first_name:    "john",
      last_name:     "doe",
      email:         "john_doe@gmail.com")
  end

  def existing_user_invite
    UserInvitation.create!(assessment_id: assessment.id,
      first_name:    "john",
      last_name:     "doe",
      email:         @user.email)
  end

  it 'creates a user account' do
    subject.new(create_valid_invite).execute
    expect(User.find_by(email: 'john_doe@gmail.com')).not_to be_nil
  end

  it 'sets the correct district for a new user' do
    subject.new(create_valid_invite).execute

    user = User.find_by(email: 'john_doe@gmail.com')
    expect(user.district_ids).to eq([@district2.id])
  end 

  it 'appends the district_id to an already existing user' do
    @user.update(district_ids: [])
    expect(@user.district_ids).not_to include([@district2.id])
    subject.new(existing_user_invite).execute

    user = User.find_by(email: @user.email)
    expect(user.district_ids).to include(@district2.id)
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
end
