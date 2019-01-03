require 'spec_helper'

describe V1::AssessmentsController do
  render_views

  before :each do
    request.env['HTTP_ACCEPT'] = 'application/json'
  end

  describe 'PUT #update' do
    let(:assessment) {
      create(:assessment, :with_participants)
    }

    let(:rubric) {
      assessment.rubric
    }

    let(:facilitator) {
      assessment.facilitators.sample
    }

    context 'when updating an existing assessment' do
      context 'when the assessment is considered valid' do
        before(:each) do
          sign_in facilitator
          put :update, params: { id: assessment.id, rubric_id: assessment.rubric }
          assessment.reload
        end

        it {
          expect(assigns(:assessment).valid?).to be true
        }

        it {
          is_expected.to respond_with :success
        }

        it {
          expect(assessment.assigned_at).to be_nil
        }
      end

      context 'when the assessment is considered invalid' do
        before(:each) do
          sign_in facilitator
          put :update, params: { id: assessment.id, rubric_id: assessment.rubric, meeting_date: 1.day.ago }
          assessment.reload
        end

        it {
          expect(assigns(:assessment).valid?).to be false
        }

        it {
          is_expected.to respond_with :bad_request
        }

        it {
          expect(assessment.assigned_at).to be_nil
        }

        it {
          expect(json['errors']['meeting_date'][0]).to include 'must be set no earlier than'
        }
      end
    end

    context 'when updating an entire record' do
      let(:time) {
        5.days.from_now
      }

      context 'when assign is not passed' do
        before(:each) do
          sign_in facilitator
          put :update, params: {
            id: assessment.id,
            rubric_id: 9001,
            name: 'some assessment',
            due_date: time,
            message: 'My message',
            another_value: 'something',
            report_takeaway: 'The takeaway'
          }
          assessment.reload
        end

        it {
          expect(assessment.rubric_id).to eq 9001
        }

        it {
          expect(assessment.name).to eq 'some assessment'
        }

        it {
          expect(assessment.message).to eq 'My message'
        }

        it {
          expect(assessment.due_date).to eq time.to_s
        }

        it {
          expect(assessment.report_takeaway).to eq 'The takeaway'
        }
      end

      context 'when assign is passed' do
        before(:each) do
          sign_in facilitator

          expect(AllParticipantsNotificationWorker).to receive(:perform_async)
                                                           .with(assessment.id)

          put :update, params: { id: assessment.id, assign: true }
          assessment.reload
        end

        it {
          is_expected.to respond_with :success
        }

        it {
          expect(assessment.assigned_at).to_not be_nil
        }
      end
    end

    context 'when not the owner of the assessment' do
      let(:non_owner) {
        create(:user, :with_district)
      }

      before(:each) do
        sign_in non_owner
        put :update, params: { id: assessment.id, rubric_id: 10000 }
      end

      it {
        is_expected.to respond_with :forbidden
      }
    end
  end

  describe 'GET #show' do
    let(:assessment) {
      create(:assessment, :with_participants)
    }

    let(:facilitator) {
      assessment.facilitators.sample
    }

    context 'when not authenticated' do
      before(:each) do
        sign_out :user
        get :show, params: { id: assessment.id }
      end

      it {
        is_expected.to respond_with :unauthorized
      }
    end

    context 'when not a participant of the assessment' do
      let(:user) {
        create(:user, :with_district)
      }

      before(:each) do
        sign_in user
        get :show, params: { id: assessment.id }
      end

      it {
        is_expected.to respond_with :forbidden
      }
    end

    context 'when authenticated' do
      context 'when message is not set on the assessment' do
        before(:each) do
          sign_in facilitator
          get :show, params: { id: assessment.id }
        end

        it {
          is_expected.to respond_with :success
        }

        it {
          assigned = assigns(:assessment)
          expect(assigned.id).to eq assessment.id
        }

        it {
          expect(json['message'].empty?).to be false
        }
      end

      xcontext 'when message is set on the assessment', 'Revisit; will be changing how messages are retrieved' do

        let(:assessment_with_message) {
          a = assessment
          a.update(message: 'welcome content')
          a
        }

        before(:each) do
          sign_in facilitator
          get :show, params: { id: assessment_with_message.id }
        end

        it {
          messages = assigns(:messages)
          expect(messages.count).to eq 1
        }

        it {
          messages = assigns(:messages)
          expect(messages.first.category).to eq('welcome')

        }

        it {
          messages = assigns(:messages)
          expect(messages.first.teaser).to eq('welcome content')
        }

        it {
          messages = assigns(:messages)
          expect(messages.first.sent_at).not_to be_nil
        }
      end

      context 'when report_takeaway is set on the assessment' do

        let(:assessment_with_report_takeaway) {
          a = assessment
          a.update(report_takeaway: 'expected takeaway')
          a
        }

        before(:each) do
          sign_in facilitator
          get :show, params: { id: assessment_with_report_takeaway.id }
        end

        it {
          expect(json['report_takeaway']).to eq('expected takeaway')
        }
      end
    end
  end

  describe 'GET #index' do
    let(:rubric) {
      create(:rubric)
    }

    let!(:assessment_list) {
      create_list(:assessment, 3, :with_participants, district: district_1, rubric: rubric)
    }

    let(:district_1) {
      create(:district)
    }

    let(:user) {
      create(:user, districts: [district_1])
    }

    context 'when the user is not authenticated' do

      before(:each) do
        sign_out :user
        get :index
      end

      it {
        is_expected.to respond_with :unauthorized
      }
    end

    context 'when the user is authenticated' do
      context 'when the user does not have a role' do
        before(:each) do
          user.update(role: nil)
          sign_in user

          get :index
        end

        it {
          is_expected.to respond_with :success
        }

        it {
          expect(assigns(:role)).to eq :district_member
        }
      end

      context 'when the user does have a role' do
        before(:each) do
          sign_in user
          get :index
        end

        it 'gets all assessments for their district' do
          result = assigns(:assessments)
          expect(result.count).to eq 3
        end
      end

      context 'when the participant has responses' do
        let!(:participant_response) {
          create(:response, responder: participant, rubric: rubric)
        }

        let(:assessment) {
          assessment_list.first
        }

        let(:participant) {
          create(:participant, user: user, assessment: assessment)
        }

        before(:each) do
          sign_in user
          get :index
        end

        it 'retrieves existing responses' do
          json_response = json.last['responses'].first
          expect(json_response['id']).to eq participant_response.id
        end
      end

      context 'when the assessment has responses' do
        let!(:assessment_response) {
          create(:response, responder: assessment, rubric: rubric, submitted_at: Time.now)
        }

        let(:assessment) {
          assessment_list.first
        }

        before(:each) do
          sign_in user
          get :index
        end

        it {
          json_response = json.last['consensus']
          expect(json_response['id']).to eq(assessment_response.id)
        }

        it {
          json_response = json.last['consensus']
          expect(json_response['submitted_at']).not_to be_nil
        }
      end

      context 'when the user is a member of the district' do

        let(:member_user) {
          create(:user, districts: [district_1, district_2])
        }

        let(:district_2) {
          create(:district)
        }

        context 'when the user role is member' do
          let!(:additional_assessment) {
            create(:assessment, :with_participants, district: district_2)
          }

          before(:each) do
            member_user.update(role: :member)
            sign_in member_user

            get :index
          end

          it {
            expect(assigns(:assessments).count).to eq 4
          }
        end

        context 'when the user is a participant of the assessment' do

          let(:assessment) {
            assessment_list.last
          }

          let!(:participant) {
            create(:participant, user: member_user, assessment: assessment)
          }

          before(:each) do
            sign_in member_user
            get :index
          end

          it {
            expect(json.first['is_participant']).to be true
          }
        end
      end
    end
  end

  describe 'POST #create' do

    let!(:rubric) {
      create(:rubric, :as_assessment_rubric)
    }

    context 'when authorized' do
      context 'when user is to become the facilitator of the project' do

        let(:facilitator) {
          create(:user, :with_district)
        }

        before(:each) do
          sign_in facilitator
          post :create, params: {
            name: 'some assessment',
            rubric_id: rubric.id,
            due_date: 5.days.from_now
          }
        end

        it {
          is_expected.to respond_with :success
        }

        it {
          expect(json['id']).not_to be_nil
        }

        it {
          expect(json['facilitator']['id']).to eq(facilitator.id)
        }

        it {
          assessment = Assessment.find(json['id'])
          expect(assessment.participant?(facilitator)).to be true
        }

        it {
          expect(ToolMember.find_by(tool: assigns(:assessment),
                                    user: facilitator,
                                    roles: [ToolMember.member_roles[:facilitator]])).to_not be_nil
        }
      end

      context 'when user is a district member' do

        let(:facilitator) {
          create(:user, :with_district, :with_network_partner_role)
        }

        before(:each) do
          sign_in facilitator
          post :create, params: {
            name: 'some assessment',
            rubric_id: rubric.id,
            due_date: 5.days.from_now
          }
        end

        it {
          assessment = Assessment.find(json['id'])
          expect(assessment.participant?(facilitator)).to be false
        }
      end

      context 'when the rubric is not provided' do
        let!(:default_rubric) {
          create(:rubric, :as_assessment_rubric)
        }

        let(:facilitator) {
          create(:user, :with_district)
        }

        before(:each) do
          sign_in facilitator
          post :create, params: { name: 'some assessment', due_date: 5.days.from_now }
        end

        it {
          expect(json['rubric_id']).to eq default_rubric.id
        }
      end

      context 'when specifying another district' do
        let(:new_district) {
          create(:district)
        }

        let(:facilitator) {
          create(:user, :with_district)
        }

        before(:each) do
          sign_in facilitator
          post :create, params: { name: 'some assessment', due_date: 5.days.from_now, district_id: new_district.id }
        end

        it {
          expect(json['district_id']).to eq new_district.id
        }
      end
    end

    context 'when no name is passed to the endpoint' do

      let(:facilitator) {
        create(:user, :with_district)
      }

      before(:each) do
        sign_in facilitator
        post :create, params: { rubric_id: rubric.id, due_date: 5.days.from_now }
      end

      it {
        expect(json['errors']['name']).to include 'can\'t be blank'
      }
    end
  end
end
