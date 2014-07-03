def active_record_error(record, field, error)
  expect(record.errors_on(field)).to include(error)
end

def no_active_record_error(record, field, error)
  expect(record.errors_on(field)).not_to include(error)
end

def create_struct
  responder = Participant.create!(user: @user)
  rubric    = @rubric
  response  = Response.create!(
    responder_type: 'Assessment', 
    responder: responder,
    rubric: rubric,
    id: 99)

  axis      = Axis.create!(name: 'something')
  category1 = Category.create!(name: "first", axis: axis)
  category2 = Category.create!(name: "second", axis: axis)
  category3 = Category.create!(name: "third")

  3.times do |i|
    question = rubric
      .questions
      .create!(category: category1, headline: "headline #{i}")
    4.times do |value|
      Answer.create!(question: question, value: value+1, content: 'some content')
    end
    Score.create!(question: question, response: response, evidence: "expected", value: 1)
  end

  3.times { rubric.questions.create!(category: category2) }
  3.times { rubric.questions.create!(category: category3) }
end


def create_responses
  response1    = Response.create(
    responder_type: 'Participant',
    responder_id:   @participant.id,
    submitted_at: Time.now)

  response2    = Response.create(
    responder_type: 'Participant',
    responder_id:   @participant2.id,
    submitted_at: Time.now)

  category1  = Category.create(name: "Some cat1")
  category2  = Category.create(name: "Some cat2")
  category3  = Category.create(name: "Some cat3")

  question1  = @rubric.questions.create(category: category1, headline: "question1")
  question2  = @rubric.questions.create(category: category2, headline: "question2")
  question3  = @rubric.questions.create(category: category3, headline: "question3")

  Score.create(value: 1, 
    response_id: response1.id, 
    question: question1)

  Score.create(value: 3, 
    response_id: response2.id, 
    question: question2)

  Score.create(value: nil, 
    response_id: response2.id, 
    question: question3)
end

def create_magic_assessments
  @district     = District.create!
  @facilitator  = Application::create_sample_user(districts: [@district])
  @facilitator2 = Application::create_sample_user(districts: [@district])
  @user         = Application::create_sample_user(districts: [@district], role: :member)
  @user2        = Application::create_sample_user(districts: [@district], role: :member)
  @user3        = Application::create_sample_user(districts: [@district], role: :member)
  @participant  = Participant.create!(user: @user)
  @participant2 = Participant.create!(user: @user2)
  @rubric       = Rubric.create!

  3.times do |i|
    Assessment.create!(
      name: "Assessment #{i}",
      rubric: @rubric,
      participants: [],
      district: @district,
      user: @facilitator,
    )
  end

  @district2    = District.create!
  @facilitator3 = Application::create_sample_user(districts: [@district2])
  @user.update(district_ids: @user.district_ids + [@district2.id])

  @assessment_with_participants = Assessment.create!(
    name: "Assessment other",
    rubric: @rubric,
    participants: [@participant, @participant2],
    district: @district2,
    user: @facilitator2,
    due_date: Time.now,
    message: 'some message',
  )
end

module Application
  class << self
    def create_user(opts = {})
      attributes = {
        email: Faker::Internet.email, 
        password: 'sup3r_s3cr3t',
        role:  :member,
        admin: false,
        first_name: 'Example',
        last_name: 'User'
      }.merge(opts)

      User.create! attributes
    end

    def create_district(opts = {})
      District.create! opts
    end

    def create_sample_user(opts = {})
      district = Application.create_district
      Application.create_user({ role: :facilitator, districts: [district]}.merge(opts))
    end
  end
end
