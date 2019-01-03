require 'spec_helper'
require_relative './tool_members_create_mail_concern'

describe V1::ToolMembersController do
  render_views
  before(:each) do
    request.env['HTTP_ACCEPT'] = 'application/json'
  end

  describe 'POST #create' do
    context 'when the user is not authenticated' do
      before(:each) do
        sign_out :user

        post :create, params: {
          tool_member: {
            tool_type: 'Assessment',
            tool_id: 1,
            role: 0,
            user_id: 1
          }
        }
      end

      it {
        is_expected.to respond_with :unauthorized
      }
    end

    context 'when the user is authenticated' do
      context 'when the user is a participant on the tool' do
        let(:user) {
          create(:user)
        }

        let(:candidate) {
          create(:user)
        }

        let(:tool) {
          create(:assessment)
        }


        let!(:tool_member) {
          create(:tool_member, :as_participant, tool: tool, user: user)
        }

        before(:each) do
          sign_in user
          post :create, params: {
            tool_member: {
              tool_type: 'Assessment',
              tool_id: tool.id,
              role: ToolMember.member_roles[:participant],
              user_id: candidate.id
            }
          }
        end

        it {
          is_expected.to respond_with :forbidden
        }
      end

      context 'when the user is a facilitator on the tool' do
        context 'when the tool is assessment' do
          it_behaves_like 'a created tool member with a specific tool', :assessment
        end

        context 'when the tool is inventory' do
          it_behaves_like 'a created tool member with a specific tool', :inventory
        end

        context 'when the tool is analysis' do
          it_behaves_like 'a created tool member with a specific tool', :analysis
        end
      end
    end
  end

  describe 'GET #show' do
    context 'when the user is not authenticated' do
      before(:each) do
        sign_out :user

        get :show, params: { tool_type: 'assessment', tool_id: 1 }
      end

      it {
        is_expected.to respond_with :unauthorized
      }
    end

    context 'when the user is authenticated' do
      let(:user) {
        create(:user)
      }

      let(:tool) {
        create(:assessment)
      }

      context 'when the passed tool name is invalid' do
        let!(:participant_user) {
          create(:tool_member, :as_participant, tool: tool, user: user)
        }

        before(:each) do
          sign_in user
          get :show, params: { tool_type: 'i_do_not_exist', tool_id: tool.id }
        end

        it {
          is_expected.to respond_with :ok
        }

        it {
          expect(json.length).to eq 0
        }
      end

      context 'when the passed tool name is valid' do
        context 'when the user is a participant on the tool' do
          let!(:participant_user) {
            create(:tool_member, :as_participant, tool: tool, user: user)
          }

          before(:each) do
            sign_in user
            get :show, params: { tool_type: 'assessment', tool_id: tool.id }
          end

          it {
            is_expected.to respond_with :ok
          }

          it {
            expect(json.length).to eq 1
          }
        end

        context 'when the user is a facilitator on the tool' do
          context 'when the user is not also a participant' do
            let!(:facilitator_user) {
              create(:tool_member, :as_facilitator, tool: tool, user: user)
            }

            before(:each) do
              sign_in user
              get :show, params: { tool_type: 'assessment', tool_id: tool.id }
            end

            it {
              is_expected.to respond_with :ok
            }

            it {
              expect(json.length).to eq 0
            }
          end

          context 'when the user is also a participant' do
            let!(:facilitator_user) {
              create(:tool_member, :as_facilitator_and_participant, tool: tool, user: user)
            }

            before(:each) do
              sign_in user
              get :show, params: { tool_type: 'assessment', tool_id: tool.id }
            end

            it {
              is_expected.to respond_with :ok
            }

            it {
              expect(json.length).to eq 1
            }
          end
        end
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when the user is not authenticated' do
      before(:each) do
        sign_out :user

        delete :destroy, params: { id: 0 }
      end

      it {
        is_expected.to respond_with :unauthorized
      }
    end

    context 'when the user is authenticated' do
      let(:user) {
        create(:user)
      }

      let(:tool) {
        create(:assessment, :with_owner)
      }
      context 'when the user is a participant on the tool' do

        let(:deleted_tool_member) {
          create(:tool_member, :as_participant, tool: tool)
        }

        let!(:tool_member) {
          create(:tool_member, :as_participant, tool: tool, user: user)
        }

        before(:each) do
          sign_in user
          delete :destroy, params: { id: deleted_tool_member.id }
        end

        it {
          is_expected.to respond_with :forbidden
        }
      end

      context 'when the user is a facilitator on the tool' do
        let!(:tool_member) {
          create(:tool_member, :as_facilitator, tool: tool, user: user)
        }

        context 'when the user being deleted is a participant' do

          let(:deleted_tool_member) {
            create(:tool_member, :as_participant, tool: tool)
          }

          let!(:deleted_tool_member_id) {
            deleted_tool_member.id
          }

          before(:each) do
            sign_in user
            delete :destroy, params: { id: deleted_tool_member.id }
          end

          it {
            is_expected.to respond_with :no_content
          }

          it {
            expect(ToolMember.where(id: deleted_tool_member_id).size).to eq 0
          }
        end

        context 'when the user being deleted does not exist' do
          before(:each) do
            sign_in user
            delete :destroy, params: { id: -1 }
          end

          it {
            is_expected.to respond_with :not_found
          }
        end

        context 'when the user being deleted is a facilitator' do
          context 'when the facilitator is not the current facilitator' do
            let(:deleted_tool_member) {
              create(:tool_member, :as_facilitator, tool: tool)
            }

            let!(:deleted_tool_member_id) {
              deleted_tool_member.id
            }

            before(:each) do
              sign_in user
              delete :destroy, params: { id: deleted_tool_member.id }
            end

            it {
              is_expected.to respond_with :no_content
            }

            it {
              expect(ToolMember.where(id: deleted_tool_member_id).size).to eq 0
            }
          end

          context 'when the facilitator is the tool owner' do
            let(:deleted_tool_member) {
              create(:tool_member, :as_facilitator, tool: tool, user: tool.owner)
            }

            before(:each) do
              sign_in user
              delete :destroy, params: { id: deleted_tool_member.id }
            end

            it {
              is_expected.to respond_with :bad_request
            }

            it {
              expect(json['errors']['base'][0]).to eq 'The owner may not be removed from this assessment.'
            }
          end

          context 'when the facilitator is the current facilitator' do
            let(:deleted_tool_member) {
              tool_member
            }

            before(:each) do
              sign_in user
              delete :destroy, params: { id: deleted_tool_member.id }
            end

            it {
              is_expected.to respond_with :bad_request
            }

            it {
              expect(json['errors']['base'][0]).to eq 'You may not remove yourself from the facilitator role.  Please ask another facilitator to handle this request.'
            }
          end
        end
      end
    end
  end

  describe 'POST #request_access' do
    context 'when the user is not authenticated' do
      before(:each) do
        sign_out :user

        post :request_access, params: {
          tool_type: 'Foo',
          tool_id: -1,
          access_request: {roles: [-2, -1]}
        }
      end

      it {
        is_expected.to respond_with :unauthorized
      }
    end

    context 'when the user is authenticated' do
      let(:user) {
        create(:user)
      }

      let(:tool) {
        create(:assessment)
      }

      context 'when the requested roles are invalid' do
        let!(:tool_member) {
          create(:tool_member, :as_participant, :as_assessment_member, user: user)
        }

        before(:each) do
          sign_in user
          post :request_access, params: {
            tool_type: tool.class.to_s,
            tool_id: tool.id,
            access_request: {roles: [-100, -101]}
          }
        end

        it {
          is_expected.to respond_with :bad_request
        }

        it {
          expect(json['errors']['base'][0]).to eq 'Invalid role(s) specified.'
        }
      end

      context 'when the user is not a member of the tool' do
        let!(:tool_member) {
          create(:tool_member, :as_participant, :as_assessment_member, user: user)
        }

        before(:each) do
          sign_in user
          post :request_access, params: {
            tool_type: tool.class.to_s,
            tool_id: tool.id,
            access_request: {roles: [0]}
          }
        end

        it {
          is_expected.to respond_with :created
        }

        it {
          expect(ToolMemberAccessRequestNotificationWorker.jobs.size).to eq 1
        }

        it {
          expect(ToolMemberAccessRequestNotificationWorker.jobs.first['args'][0]).to eq assigns(:request).id
        }

        it {
          expect(assigns[:request].roles).to eq ['facilitator']
        }
      end

      context 'when the user is a member of the tool' do
        context 'when the user is already a participant' do
          let!(:tool_member) {
            create(:tool_member, :as_participant, tool: tool, user: user)
          }

          before(:each) do
            sign_in user
            post :request_access, params: {
              tool_type: tool.class.to_s,
              tool_id: tool.id,
              access_request: {roles: [1]}
            }
          end

          it {
            is_expected.to respond_with :bad_request
          }

          it {
            expect(json['errors']['base'][0]).to eq "Access for #{user.email} for #{tool.name} already exists at these levels: participant"
          }
        end

        context 'when the user is already a participant but not a facilitator' do
          let!(:tool_member) {
            create(:tool_member, :as_participant, tool: tool, user: user)
          }

          before(:each) do
            sign_in user
            post :request_access, params: {
              tool_type: tool.class.to_s,
              tool_id: tool.id,
              access_request: {roles: [0]}
            }
          end

          it {
            is_expected.to respond_with :created
          }

          it {
            expect(ToolMemberAccessRequestNotificationWorker.jobs.size).to eq 1
          }

          it {
            expect(ToolMemberAccessRequestNotificationWorker.jobs.first['args'][0]).to eq assigns(:request).id
          }

          it {
            expect(assigns[:request].roles).to eq ['facilitator']
          }
        end

        context 'when the user is already a facilitator' do
          let!(:tool_member) {
            create(:tool_member, :as_facilitator, tool: tool, user: user)
          }

          before(:each) do
            sign_in user
            post :request_access, params: {
              tool_type: tool.class.to_s,
              tool_id: tool.id,
              access_request: {roles: [0]}
            }
          end

          it {
            is_expected.to respond_with :bad_request
          }

          it {
            expect(json['errors']['base'][0]).to eq "Access for #{user.email} for #{tool.name} already exists at these levels: facilitator"
          }
        end

        context 'when the user is already a facilitator but not a participant' do
          let!(:tool_member) {
            create(:tool_member, :as_facilitator, tool: tool, user: user)
          }

          before(:each) do
            sign_in user
            post :request_access, params: {
              tool_type: tool.class.to_s,
              tool_id: tool.id,
              access_request: {roles: [1]}
            }
          end

          it {
            is_expected.to respond_with :created
          }

          it {
            expect(ToolMemberAccessRequestNotificationWorker.jobs.size).to eq 1
          }

          it {
            expect(ToolMemberAccessRequestNotificationWorker.jobs.first['args'][0]).to eq assigns(:request).id
          }

          it {
            expect(assigns[:request].roles).to eq ['participant']
          }
        end

        context 'when the user is already a facilitator and participant' do
          let!(:tool_member) {
            create(:tool_member, :as_facilitator_and_participant, tool: tool, user: user)
          }

          let(:roles) {
            MembershipHelper.humanize_roles(ToolMember.where(tool: tool, user: user).first.roles)
          }

          before(:each) do
            sign_in user
            post :request_access, params: {
              tool_type: tool.class.to_s,
              tool_id: tool.id,
              access_request: {roles: [0, 1]}
            }
          end

          it {
            is_expected.to respond_with :bad_request
          }

          it {
            expect(json['errors']['base'][0]).to eq(
              "Access for #{user.email} for #{tool.name} already exists at these levels: #{roles.join(', ')}"
            )
          }
        end
      end
    end
  end

  describe 'POST #grant' do
    context 'when the user is not authenticated' do
      before(:each) do
        sign_out :user

        post :grant, params: { tool_type: 'Foo', tool_id: -1, id: -1 }
      end

      it {
        is_expected.to respond_with :unauthorized
      }
    end

    context 'when the user is authenticated' do
      let(:user) {
        create(:user)
      }

      let(:tool) {
        create(:assessment, :with_owner)
      }

      context 'when the user is a participant on the tool' do
        let!(:tool_member) {
          create(:tool_member, :as_participant, tool: tool, user: user)
        }

        before(:each) do
          sign_in user
          post :grant, params: { tool_type: tool.class.to_s, tool_id: tool.id, id: -1 }
        end

        it {
          is_expected.to respond_with :forbidden
        }
      end

      context 'when the user is a facilitator on the tool' do
        let!(:tool_member) {
          create(:tool_member, :as_facilitator, tool: tool, user: user)
        }

        context 'when no access request exists' do
          before(:each) do
            sign_in user
            post :grant, params: { tool_type: tool.class.to_s, tool_id: tool.id, id: 1 }
          end

          it {
            is_expected.to respond_with :not_found
          }
        end

        context 'when an access request exists' do
          context 'when the access request contains only a facilitator role' do
            let(:access_request) {
              create(:access_request, :with_facilitator_role, tool: tool)
            }

            let!(:access_request_id) {
              access_request.id
            }
            
            before(:each) do
              sign_in user
              post :grant, params: { tool_type: tool.class.to_s, tool_id: tool.id, id: access_request.id }
            end
            
            it {
              is_expected.to respond_with :ok
            }

            it {
              expect(json.size).to eq 1
            }

            it {
              expect(json['user']['tool_id']).to eq tool.id
            }

            it {
              expect(json['user']['tool_type']).to eq tool.class.to_s
            }

            it {
              expect(json['user']['roles'].include?(ToolMember.member_roles[:facilitator])).to be true
            }

            it {
              expect(json['user']['id']).to eq access_request.user.id
            }

            it {
              expect(AccessRequest.find_by(id: access_request_id)).to be nil
            }
          end

          context 'when the access request contains only a participant role' do
            let(:access_request) {
              create(:access_request, :with_participant_role, tool: tool)
            }

            let!(:access_request_id) {
              access_request.id
            }

            before(:each) do
              sign_in user
              post :grant, params: { tool_type: tool.class.to_s, tool_id: tool.id, id: access_request.id }
            end

            it {
              is_expected.to respond_with :ok
            }

            it {
              expect(json.size).to eq 1
            }

            it {
              expect(json['user']['tool_id']).to eq tool.id
            }

            it {
              expect(json['user']['tool_type']).to eq tool.class.to_s
            }

            it {
              expect(json['user']['roles'].include?(ToolMember.member_roles[:participant])).to be true
            }

            it {
              expect(json['user']['id']).to eq access_request.user.id
            }

            it {
              expect(AccessRequest.find_by(id: access_request_id)).to be nil
            }
          end

          context 'when the access request contains both a facilitator and a participant role' do
            let(:access_request) {
              create(:access_request, :with_both_roles, tool: tool)
            }

            let!(:access_request_id) {
              access_request.id
            }

            before(:each) do
              sign_in user
              post :grant, params: { tool_type: tool.class.to_s, tool_id: tool.id, id: access_request.id }
            end

            it {
              is_expected.to respond_with :ok
            }

            it {
              expect(json['user']['tool_id']).to eq tool.id
            }

            it {
              expect(json['user']['tool_type']).to eq tool.class.to_s
            }

            it {
              expect(json['user']['roles'].include?(ToolMember.member_roles[:participant])).to be true
            }

            it {
              expect(json['user']['roles'].include?(ToolMember.member_roles[:facilitator])).to be true
            }

            it {
              expect(json['user']['id']).to eq access_request.user.id
            }

            it {
              expect(AccessRequest.find_by(id: access_request_id)).to be nil
            }
          end
        end
      end
    end
  end

  describe 'POST #deny' do
    context 'when the user is not authenticated' do
      before(:each) do
        sign_out :user

        post :deny, params: { tool_type: 'Foo', tool_id: -1, id: -1 }
      end

      it {
        is_expected.to respond_with :unauthorized
      }
    end

    context 'when the user is authenticated' do
      let(:user) {
        create(:user)
      }

      let(:tool) {
        create(:assessment, :with_owner)
      }

      context 'when the user is a participant on the tool' do
        let!(:tool_member) {
          create(:tool_member, :as_participant, tool: tool, user: user)
        }

        before(:each) do
          sign_in user
          post :deny, params: { tool_type: tool.class.to_s, tool_id: tool.id, id: -1 }
        end

        it {
          is_expected.to respond_with :forbidden
        }
      end

      context 'when the user is a facilitator on the tool' do
        let!(:tool_member) {
          create(:tool_member, :as_facilitator, tool: tool, user: user)
        }

        context 'when no access request exists' do
          before(:each) do
            sign_in user
            post :deny, params: { tool_type: tool.class.to_s, tool_id: tool.id, id: 1 }
          end

          it {
            is_expected.to respond_with :not_found
          }
        end

        context 'when an access request exists' do
          let(:access_request) {
            create(:access_request, :with_both_roles, tool: tool)
          }

          let!(:access_request_id) {
            access_request.id
          }

          before(:each) do
            sign_in user
            post :deny, params: { tool_type: tool.class.to_s, tool_id: tool.id, id: access_request.id }
          end

          it {
            is_expected.to respond_with :no_content
          }

          it {
            expect(AccessRequest.find_by(id: access_request_id)).to be nil
          }
        end
      end
    end
  end
end
