require 'spec_helper'

describe V1::UserInvitationsController do
  render_views

  before(:each) do
    request.env["HTTP_ACCEPT"] = 'application/json'
  end

  describe '#create' do
    let(:assessment) {
      create(:assessment, :with_participants)
    }

    context 'when the user is not authenticated' do
      before(:each) do
        sign_out :user
        post :create, params: { assessment_id: assessment.id }
      end

      it {
        is_expected.to respond_with :unauthorized
      }
    end

    context 'when user is not a facilitator' do
      let(:user) {
        assessment.participants.sample.user
      }

      before(:each) do
        sign_in user
        post :create, params: { assessment_id: assessment.id }
      end

      it {
        is_expected.to respond_with :forbidden
      }
    end

    context 'when the user is a facilitator' do
      let(:user) {
        assessment.facilitators.sample
      }

      context 'when the user has not been invited prior' do
        context 'when no team role is specified' do
          before(:each) do
            sign_in user
            post :create, params: {
              assessment_id: assessment.id,
              first_name: "john",
              last_name: "doe",
              email: "john_doe@gmail.com"
            }
          end

          it {
            is_expected.to respond_with :success
          }

          it {
            expect(UserInvitation.where(email: 'john_doe@gmail.com').first).to_not be_nil
          }

          it {
            expect(UserInvitation.where(email: 'john_doe@gmail.com').first.team_role).to be_nil
          }
        end

        context 'when the team role is specified' do
          before(:each) do
            sign_in user
            post :create, params: {
              assessment_id: assessment.id,
              first_name: "john",
              last_name: "doe",
              email: "john_doe@gmail.com",
              team_role: 'Finance'
            }
          end

          it {
            is_expected.to respond_with :success
          }

          it {
            expect(UserInvitation.where(email: 'john_doe@gmail.com').first).to_not be_nil
          }

          it {
            expect(UserInvitation.where(email: 'john_doe@gmail.com').first.team_role).to eq 'Finance'
          }
        end
      end

      context 'when the user has been invited prior' do
        let!(:prior_invitation) {
          create(:user_invitation,
                 last_name: 'doe',
                 first_name: 'john',
                 email: 'john_doe@gmail.com',
                 assessment_id: assessment.id)
        }

        before(:each) do
          sign_in user
          post :create, params: {
            assessment_id: assessment.id,
            first_name: "john",
            last_name: "doe",
            email: "john_doe@gmail.com"
          }
        end

        it {
          is_expected.to respond_with :unprocessable_entity
        }

        it {
          expect(json["errors"]["email"]).to include "User has already been invited"
        }
      end

      context 'when the :send_invite flag is not passed' do
        before(:each) do
          sign_in user
          post :create, params: {
            assessment_id: assessment.id,
            first_name: "john",
            last_name: "doe",
            email: "john_doe@gmail.com"
          }
        end

        it {
          expect(UserInvitationNotificationWorker.jobs.count).to eq 0
        }
      end

      context 'when the :send_invite flag is passed' do
        before(:each) do
          sign_in user
          post :create, params: {
            assessment_id: assessment.id,
            first_name: "john",
            last_name: "doe",
            email: "john_doe@gmail.com",
            send_invite: true
          }
        end

        it {
          expect(UserInvitationNotificationWorker.jobs.count).to eq 1
        }
      end

      context 'when the user is already invited to one assessment' do
        let(:other_assessment) {
          create(:assessment, :with_participants)
        }

        let(:other_user) {
          other_assessment.facilitators.sample
        }

        let!(:prior_invitation) {
          create(:user_invitation,
                 last_name: 'doe',
                 first_name: 'john',
                 email: 'john_doe@gmail.com',
                 assessment_id: assessment.id)
        }

        before(:each) do
          sign_in other_user
          post :create, params: {
            assessment_id: other_assessment.id,
            first_name: "john",
            last_name: "doe",
            email: "john_doe@gmail.com"
          }
        end

        it {
          is_expected.to respond_with :success
        }

        it {
          expect(UserInvitation.where(email: 'john_doe@gmail.com').size).to eq 2
        }
      end

      context 'when the facilitator role is provided' do
        before(:each) do
          sign_in user
          post :create, params: {
            assessment_id: assessment.id,
            first_name: "john",
            last_name: "doe",
            email: "john_doe@gmail.com",
            role: "facilitator"
          }
        end

        it {
          expect(
              assessment.facilitator?(User.find_by(email: 'john_doe@gmail.com'))).to be true
        }
      end
    end
  end
end
