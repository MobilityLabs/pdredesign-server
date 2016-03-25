# == Schema Information
#
# Table name: user_invitations
#
#  id            :integer          not null, primary key
#  first_name    :string(255)
#  last_name     :string(255)
#  email         :string(255)
#  team_role     :string(255)
#  token         :string(255)
#  assessment_id :integer
#  user_id       :integer
#

require 'spec_helper' 

describe UserInvitation do
  let(:subject) { UserInvitation }
  it 'requires an email' do
    record = subject.new(email: nil)

    expect(record.valid?).to eq(false)
    expect(record.errors_on(:email)).not_to be_empty

    record = subject.new(email: 'some@user.com')
    expect(record.errors_on(:email)).to be_empty
  end

  it 'dowcases an email address' do
    record = subject.create!(
      assessment_id: 1,
      email: 'SomeUserEmail@user.com')
    expect(record.email).to eq('someuseremail@user.com')
  end

  it 'requires an assessment_id' do
    record = subject.new(assessment_id: nil)
    expect(record.valid?).to eq(false)
    expect(record.errors_on(:assessment_id)).not_to be_empty

    record = subject.new(assessment_id: 1)
    expect(record.valid?).to eq(false)
    expect(record.errors_on(:assessment_id)).to be_empty
  end

  it 'creates a valid user invite' do
    record = subject.create!(assessment_id: 1,
                             email: 'some@user.com')
    expect(record.valid?).to eq(true)
  end

  it 'creates a onetime token' do
    record = subject.create!(
      assessment_id: 1,
      email: 'some@user.com')

    expect(record.token).not_to be_nil
    expect(record.token.length).to eq(10)

    old_token = record.token
    record.update(email: 'some@other.com')
    expect(record.token).to eq(old_token)
  end

  it 'does not create a token if one is given during create' do
    record = subject.create!(
      assessment_id: 1,
      token: 'expected_token',
      email: 'some@user.com')
    expect(record.token).to eq('expected_token')
  end

  it 'should accept the role field' do
    record = subject.create!(
      assessment_id: 1,
      token: 'expected_token',
      email: 'some@user.com',
      role:  'facilitator')
    expect(record.role).to eq('facilitator')
  end

end
