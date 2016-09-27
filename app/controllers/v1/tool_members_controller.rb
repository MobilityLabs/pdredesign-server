class V1::ToolMembersController < ApplicationController
  include MembershipHelper

  before_action :authenticate_user!
  before_action :normalize_strong_param_tool_type!, only: [:create]
  before_action :normalize_path_param_tool_type!, only: [:show, :request_access]

  def create
    tool_member = ToolMember.create(tool_member_params)
    authorize_action_for tool_member
    if tool_member.save
      render nothing: true, status: :created
    else
      @errors = tool_member.errors
      render 'v1/shared/errors', errors: @errors, status: :bad_request
    end
  end

  def show
    @tool_members = ToolMember.includes(:response, :user)
                        .where(tool_id: params[:tool_id],
                               tool_type: params[:tool_type],
                               role: ToolMember.member_roles[:participant])
  end

  def destroy
    tool_member = ToolMember.includes(:user).find_by(id: params[:id])

    if tool_member.nil?
      return render nothing: true, status: :not_found
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
      render nothing: true, status: :no_content
    else
      @errors = tool_member.errors
      render 'v1/shared/errors', errors: @errors, status: :bad_request
    end
  end

  authority_actions request_access: :read

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
        return render nothing: true, status: :created
      end
    end

    @errors = @request.errors
    render 'v1/shared/errors', errors: @errors, status: :bad_request
  end

  private
  def member_is_owner(tool_member)
    tool_member.role == ToolMember.member_roles[:facilitator] &&
        MembershipHelper.owner_on_instance?(tool_member, tool_member.user)
  end

  def tool_member_params
    params.require(:tool_member).permit(:tool_type, :tool_id, :role, :user_id)
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
    tool_member_query = ToolMember.where(tool: @request.tool,
                                         user: @request.user,
                                         role: MembershipHelper.dehumanize_roles(@request.roles))
    unless tool_member_query.empty?
      roles = MembershipHelper.humanize_roles(tool_member_query.map(&:role))
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

  def send_access_granted_email(tool_member)
    worker_args = [tool_member.tool_id,
                   tool_member.user_id,
                   MembershipHelper.humanize_role(tool_member.role)]

    case tool_member.tool.class.to_s
      when 'Assessment'
        AccessGrantedNotificationWorker.perform_async(*worker_args)
      when 'Inventory'
        InventoryAccessGrantedNotificationWorker.perform_async(*worker_args)
      when 'Analysis'
        AnalysisAccessGrantedNotificationWorker.perform_async(*worker_args)
      else
        raise "No access granted notification worker for #{tool_member.tool_type} defined!"
    end
  end
end