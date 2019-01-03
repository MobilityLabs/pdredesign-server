class ToolMemberAccessRequestNotificationWorker
  include Sidekiq::Worker

  def perform(request_id)
    request = AccessRequest.find_by(id: request_id)
    tool = request.tool

    ToolMember.includes(:user).where(tool: tool)
        .where('? = ANY(roles)', ToolMember.member_roles[:facilitator])
        .uniq
        .each do |facilitator|
      args = [request, facilitator.user.email]
      case tool.class.to_s

        when 'Assessment'
          AccessRequestMailer.send(:request_access, *args).deliver_now
        when 'Inventory'
          InventoryAccessRequestMailer.send(:request_access, *args).deliver_now
        when 'Analysis'
          AnalysisAccessRequestMailer.send(:request_access, *args).deliver_now
      end
    end
  end
end
