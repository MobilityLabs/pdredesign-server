require 'spec_helper'

describe V1::AssessmentsController do
  render_views

  before :each do
    request.env["HTTP_ACCEPT"] = 'application/json'
  end

  context '#update' do
    before { create_magic_assessments }
    before { sign_in @facilitator2 }
    let(:assessment) { @assessment_with_participants }

    it 'can update an assessment' do
      put :update, {id: assessment.id, rubric_id: 42}
      assert_response :success
    end

    it 'updates the record' do
      time = Time.now
      put :update, {id: assessment.id, 
                    rubric_id: 42,
                    name: 'some assessment',
                    due_date: time,
                    message: 'My message',
                    another_value: 'something'}

      assessment.reload
      expect(assessment.rubric_id).to eq(42)
      expect(assessment.name).to eq('some assessment')
      expect(assessment.message).to eq('My message')
      expect(assessment.due_date).to eq(time.to_s)
    end

    it 'only allows the owner to update' do
      sign_in @facilitator
      put :update, {id: assessment.id, rubric_id: 42}
      assert_response :forbidden
    end

    it 'does not set :assigned_at' do
      put :update, id: assessment.id, rubric_id: 42
      assert_response :success

      updated_assessment = Assessment.find(assessment.id)
      expect(updated_assessment.assigned_at).to be_nil
    end

    it 'sets :assigned_at when :assign present' do
      put :update, assign: true, id: assessment.id, rubric_id: 42
      assert_response :success

      updated_assessment = Assessment.find(assessment.id)
      expect(updated_assessment.assigned_at).not_to be_nil
    end
  end

  context '#show' do
    before { create_magic_assessments }
    before { sign_in @facilitator2 }
    let(:assessment) { @assessment_with_participants }

    it 'can retreive the assessment' do
      get :show, id: assessment.id
      assigned = assigns(:assessment)

      expect(assigned.id).to eq(assessment.id)
      assert_response :success
    end

   context 'permissions' do
      it 'requires a logged in user' do
        sign_out :user

        get :show, id: 1
        assert_response :unauthorized
      end

      it 'forbids a non-participant access' do
        sign_in @user
        unauthorized = Assessment.find_by_name("Assessment 1")
        get :show, id: unauthorized.id

        assert_response :forbidden
      end

      it 'forbids facilitator in another district' do
        sign_in @facilitator3

        unauthorized = Assessment.find_by_name("Assessment 1")
        get :show, id: unauthorized.id
        assert_response :forbidden
      end

      it 'allows a facilitator from the same district' do
        user = Application::create_sample_user(districts: [@district2])
        sign_in user

        get :show, id: assessment.id
        assert_response :success
      end
    end
  end

  context '#index' do
    before { create_magic_assessments }

    it 'requires a user logged in user' do
      sign_out :user

      get :index
      assert_response :unauthorized
    end

    it 'gets a facilitators assessments' do
      sign_in @facilitator

      get :index
      assessments = assigns(:assessments)

      expect(assessments.count).to eq(3)
    end

    it 'gets a members assessments' do
      @user.update(role: :member)
      sign_in @user

      get :index
      assessments = assigns(:assessments)

      expect(assessments.count).to eq(1)
    end

    it 'returns the current users responses' do
      response = Response.create(responder_id:   @participant.id,
                                 responder_type: 'Participant',
                                 rubric: @rubric) 
      sign_in @user
      get :index
      json_response = json.first["responses"].first
      expect(json_response["id"]).to eq(response.id)
    end

    it 'returns is_participant if current_user is a participant' do
      sign_in @user
      get :index

      expect(json.first["is_participant"]).to eq(true)
    end


    it 'returns a consensus_id and submitted_at if present' do
      time = Time.now
      consensus = Response.create(responder_id:   @assessment_with_participants.id,
                                  responder_type: 'Assessment',
                                  rubric: @rubric,
                                  submitted_at: time) 
      sign_in @user
      get :index

      json_response = json.first
      expect(json_response["consensus"]["id"]).to eq(consensus.id)
      expect(json_response["consensus"]["submitted_at"]).not_to be_nil

    end
  end

  context '#show' do
    before { create_magic_assessments }
    before { sign_in @facilitator2 }
    let(:assessment) { @assessment_with_participants }

    it 'always returns the welcome message' do
      assessment.update(message: 'welcome content')

      get :show, id: assessment.id
      messages = assigns(:messages)

      expect(messages.count).to eq(1)
      expect(messages.first.category).to    eq("welcome")
      expect(messages.first.teaser).to     eq("welcome content")
      expect(messages.first.sent_at).not_to be_nil
    end

    it 'returns a default message when one is not assigned' do
      assessment.update(message: nil)
      get :show, id: assessment.id

      expect(json["message"].empty?).to eq(false)
    end
  end

  context '#create' do
    before { create_magic_assessments }
    before { sign_in @facilitator }

    it 'does not allow non-facilitators to create an assessment' do
      sign_in @user  
      post :create, name: 'some assessment'
      assert_response :forbidden
    end

    it 'allows a facilitator to create an assessment' do
      post :create, 
        name: 'some assessment', 
        rubric_id: @rubric.id,
        due_date: Time.now

      assert_response :success
    end

    it 'sets the facilitator correctly' do
      post :create, 
        name: 'some assessment', 
        rubric_id: @rubric.id,
        due_date: Time.now

      expect(json["facilitator"]["id"]).to eq(@facilitator.id)
    end

    it 'creates a record' do
      post :create, 
        name: 'some assessment', 
        rubric_id: @rubric.id,
        due_date: Time.now

      expect(json["id"]).not_to be_nil
    end

    it 'returns json errors when an assessment cant be created' do
      post :create, 
        rubric_id: @rubric.id,
        due_date: Time.now

      expect(json["errors"]["name"]).to include("can't be blank")
    end
  end
end
