class V1::ToolMembersController < ApplicationController
  include MembershipHelper

  before_action :authenticate_user!
  before_action :normalize_strong_param_tool_type!, only: [:create, :update]
  before_action :normalize_path_param_tool_type!, except: [:destroy, :create, :batch_update]

  def create
    tool_member = ToolMember.find_or_create_by(tool_type: tool_member_params[:tool_type],
                                               tool_id: tool_member_params[:tool_id],
                                               user_id: tool_member_params[:user_id])
    authorize_action_for tool_member
    previous_roles = tool_member.roles
    tool_member.roles = tool_member_params[:roles]
    new_record = tool_member.new_record?
    if tool_member.save
      notifiable_roles(previous_roles, tool_member.roles).each { |role|
        send_access_granted_email(tool_member, MembershipHelper.humanize_role(role))
      }
      tool_member.tool.save
      head (new_record ? :created : :no_content)
    else
      @errors = tool_member.errors
      render 'v1/shared/errors', errors: @errors, status: :bad_request
    end
  end

  def show
    @tool_members = ToolMember.
      includes(:response, :user).
      where(tool_id: params[:tool_id], tool_type: params[:tool_type]).
      where('? = ANY(roles)', ToolMember.member_roles[:participant])
  end

  def show_all
    @tool_members = ToolMember.includes(:response, :user)
                        .where(tool_id: params[:tool_id],
                               tool_type: params[:tool_type])

  end

  def destroy
    tool_member = ToolMember.includes(:user).find_by(id: params[:id])

    if tool_member.nil?
      head :not_found
      return
    end

    authorize_action_for tool_member

    if member_is_owner(tool_member)
      tool_member.errors.add(:base, "The owner may not be removed from this #{tool_member.tool_type.downcase}.")
    end

    if MembershipHelper.facilitator_on_instance?(tool_member, current_user)
      tool_member.errors.add(:base, 'You may not remove yourself from the facilitator role.  Please ask another facilitator to handle this request.')
    end

    if tool_member.errors.empty?
      tool_member.destroy
      head :no_content
    else
      @errors = tool_member.errors
      render 'v1/shared/errors', errors: @errors, status: :bad_request
    end
  end

  def request_access
    @request = AccessRequest.create(
        user: current_user,
        tool_type: params[:tool_type],
        tool_id: params[:tool_id],
        roles: MembershipHelper.humanize_roles(tool_member_access_request_params[:roles])
    )

    validate_access_request

    if @request.errors.empty?
      if @request.save
        send_access_requested_email(@request)
        head :created
        return
      end
    end

    @errors = @request.errors
    render 'v1/shared/errors', errors: @errors, status: :bad_request
  end

  def grant
    tool_member = ToolMember.find_by(tool_type: params[:tool_type],
                                     tool_id: params[:tool_id],
                                     user: current_user)
    authorize_action_for tool_member

    access_request_query = AccessRequest.includes(:tool).where(id: params[:id])
    if access_request_query.size == 0
      head :not_found
      return
    end

    access_request = access_request_query.first

    @candidate = ToolMember.new(tool: access_request.tool,
                                roles: MembershipHelper.dehumanize_roles(access_request.roles),
                                user: access_request.user)

    access_request.destroy
    render 'v1/tool_members/grant'
  end

  authority_actions grant: :create

  def deny
    tool_member = ToolMember.find_by(tool_type: params[:tool_type],
                                     tool_id: params[:tool_id],
                                     user: current_user)
    authorize_action_for tool_member

    access_request_query = AccessRequest.includes(:tool).where(id: params[:id])
    if access_request_query.size == 0
      head :not_found
      return
    end

    access_request_query.first.destroy
    head :no_content
  end

  authority_actions deny: :create

  def invitable_members
    tool_member = ToolMember.find_by(tool_type: params[:tool_type],
                                     tool_id: params[:tool_id])

    authorize_action_for tool_member
    tool = tool_member.tool

    unless tool
      head :not_found
      return
    end

    @users = User.includes(:districts).where(districts: {id: tool.district_id})
                 .where.not(team_role: 'network_partner', id: ToolMember.where(tool_type: params[:tool_type],
                                                                               tool_id: params[:tool_id]).select(:user_id).pluck(:user_id))
  end

  authority_actions invitable_members: :create

  def permission_requests
    tool_member = ToolMember.find_by(tool_type: params[:tool_type],
                                     tool_id: params[:tool_id])

    unless tool_member
      head :not_found
      return
    end

    authorize_action_for tool_member
    tool = tool_member.tool

    @requests = AccessRequest.where(tool: tool)
  end

  authority_actions permission_requests: :create

  private
  def member_is_owner(tool_member)
    tool_member.roles.include?(ToolMember.member_roles[:facilitator]) &&
        MembershipHelper.owner_on_instance?(tool_member)
  end

  def tool_member_params
    params.require(:tool_member).permit(:tool_type, :tool_id, :user_id, roles: [])
  end

  def notifiable_roles(original_roles, new_roles)
    (original_roles | new_roles) - original_roles
  end

  def tool_member_access_request_params
    params.require(:access_request).permit(roles: [])
  end

  def normalize_strong_param_tool_type!
    params[:tool_member][:tool_type] = params[:tool_member][:tool_type].titlecase
  end

  def normalize_path_param_tool_type!
    params[:tool_type] = params[:tool_type].titlecase
  end

  def validate_access_request
    tool_member_query = ToolMember.
      where(tool: @request.tool, user: @request.user).
      where('roles @> ARRAY[?]::integer[]', MembershipHelper.dehumanize_roles(@request.roles))

    unless tool_member_query.empty?
      roles = MembershipHelper.humanize_roles(tool_member_query.first.roles)
      @request.errors.add(:base, "Access for #{@request.user.email} for #{@request.tool.name} already exists at these levels: #{roles.join(', ')}")
    end

    if (ToolMember.member_roles.values.collect { |val| val.to_s } &
        tool_member_access_request_params[:roles]).size !=
        tool_member_access_request_params[:roles].size
      @request.errors.add(:base, 'Invalid role(s) specified.')
    end
  end

  def send_access_requested_email(request)
    ToolMemberAccessRequestNotificationWorker.perform_async(request.id)
  end

  def send_access_granted_email(tool_member, role)
    worker_args = [tool_member.tool_id,
                   tool_member.user_id,
                   role]

    case tool_member.tool.class.to_s
      when 'Assessment'
        AccessGrantedNotificationWorker.send(:perform_async, *worker_args)
      when 'Inventory'
        InventoryAccessGrantedNotificationWorker.send(:perform_async, *worker_args)
      when 'Analysis'
        AnalysisAccessGrantedNotificationWorker.send(:perform_async, *worker_args)
      else
        raise "No access granted notification worker for #{tool_member.tool_type} defined!"
    end
  end
end
