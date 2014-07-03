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

end
