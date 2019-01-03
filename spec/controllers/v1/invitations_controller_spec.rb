require 'spec_helper'

describe V1::InvitationsController do
  before(:each) do
    request.env['HTTP_ACCEPT'] = 'application/json'
  end
  render_views

  describe 'POST #redeem' do
    context 'when an invitation is not found' do
      before(:each) do
        post :redeem, params: { token: 'token' }
      end

      it {
        is_expected.to respond_with :not_found
      }
    end

    context 'when an invitation is found' do
      context 'when the user account exists' do
        let(:user) {
          create(:user, :with_district)
        }

        let(:user_invitation) {
          create(:user_invitation, email: user.email)
        }

        before(:each) do
          post :redeem, params: { token: user_invitation.token }
        end

        it {
          is_expected.to respond_with :success
        }

        it {
          expect(controller.current_user).to eq user
        }

        it {
          expect(UserInvitation.find_by(token: user_invitation.token)).to be_nil
        }
      end

      context 'when the user account does not exist' do
        let(:user_invitation) {
          create(:user_invitation, email: 'doesnotexisteveratallnope@example.com')
        }

        before(:each) do
          post :redeem, params: { token: user_invitation.token }
        end

        it {
          expect(controller.current_user).to be_nil
        }

        it {
          is_expected.to respond_with :unauthorized
        }
      end

      context 'when passing information to update the user with' do
        let(:user) {
          create(:user, :with_district)
        }

        let(:user_invitation) {
          create(:user_invitation, email: user.email)
        }

        context 'when updating the first name' do
          before(:each) do
            post :redeem, params: { token: user_invitation.token, first_name: '1OptimusPrime' }
            user.reload
          end

          it {
            is_expected.to respond_with :success
          }

          it {
            expect(user.first_name).to eq '1OptimusPrime'
          }
        end

        context 'when updating the last name' do
          before(:each) do
            post :redeem, params: { token: user_invitation.token, last_name: '2Autobots' }
            user.reload
          end

          it {
            is_expected.to respond_with :success
          }


          it {
            expect(user.last_name).to eq '2Autobots'
          }
        end

        context 'when updating the team role' do
          before(:each) do
            post :redeem, params: { token: user_invitation.token, team_role: '3LevitatingGuru' }
            user.reload
          end

          it {
            is_expected.to respond_with :success
          }

          it {
            expect(user.team_role).to eq '3LevitatingGuru'
          }
        end

        context 'when updating the email' do
          before(:each) do
            post :redeem, params: { token: user_invitation.token, email: '4email@example.com' }
            user.reload
          end

          it {
            is_expected.to respond_with :success
          }

          it {
            expect(user.email).to eq '4email@example.com'
          }
        end

        context 'when updating the password' do
          context 'when the password is invalid' do
            before(:each) do
              post :redeem, params: { token: user_invitation.token, password: '123' }
            end

            it {
              is_expected.to respond_with :unprocessable_entity
            }
          end

          context 'when the password is valid' do
            before(:each) do
              post :redeem, params: { token: user_invitation.token, password: 'avalidpassword' }
            end

            it {
              is_expected.to respond_with :success
            }
          end
        end
      end
    end
  end

  describe 'GET #show' do
    context 'when an assessment invitation is found' do
      let(:user) {
        create(:user, :with_district)
      }

      let(:user_invitation) {
        create(:user_invitation, email: user.email)
      }

      before(:each) do
        get :show, params: { token: user_invitation.token }
      end

      it {
        is_expected.to respond_with :success
      }

      it {
        expect(json['token']).to be_nil
      }

      it {
        expect(json['email']).to eq user_invitation.email
      }

      it {
        expect(json['assessment_id']).to eq user_invitation.assessment.id
      }
    end

    context 'when an inventory invitation is found' do
      let(:user) {
        create(:user, :with_district)
      }

      let(:invitation) {
        create(:inventory_invitation, user: user, email: user.email)
      }

      before(:each) do
        get :show, params: { token: invitation.token }
      end

      it {
        is_expected.to respond_with :success
      }

      it {
        expect(json['token']).to be_nil
      }

      it {
        expect(json['email']).to eq invitation.email
      }

      it {
        expect(json['inventory_id']).to eq invitation.inventory.id
      }
    end
  end
end
