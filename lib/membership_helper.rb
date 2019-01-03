module MembershipHelper
  def self.participant?(tool, user)
    ToolMember.where(tool: tool, user: user)
        .where('? = ANY(roles)', ToolMember.member_roles[:participant]).exists?
  end

  def self.facilitator?(tool, user)
    ToolMember.where(tool: tool, user: user)
        .where('? = ANY(roles)', ToolMember.member_roles[:facilitator]).exists?
  end

  def self.member?(tool, user)
    ToolMember.where(tool: tool, user: user).exists?
  end

  def self.network_partner?(tool, user)
    ToolMember.includes(:user)
        .where(tool: tool, user: user, users: {role: 'network_partner'})
        .exists?
  end

  def self.facilitator_on_instance?(tool_member, user)
    tool_member.user == user && tool_member.roles.include?(ToolMember.member_roles[:facilitator])
  end

  def self.participant_on_instance?(tool_member, user)
    tool_member.user == user && tool_member.roles.include?(ToolMember.member_roles[:participant])
  end

  def self.owner_on_instance?(tool_member)
    tool_member.tool.owner_id == tool_member.user_id
  end

  def self.status(tool_member)
    return :pending if tool_member.invited_at.nil?
    return :invited if tool_member.response.nil?
    return :in_progress if tool_member.response.submitted_at.nil?
    :completed
  end

  def self.date(tool_member, status)
    return tool_member.tool.updated_at if status == :pending
    return tool_member.invited_at if status == :invited
    return tool_member.response.updated_at if status == :in_progress
    tool_member.response.submitted_at
  end

  def self.humanize_role(role_value)
    ToolMember.member_roles.keys[role_value]
  end

  def self.humanize_roles(role_values)
    role_values.uniq.collect { |role| MembershipHelper.humanize_role(role.to_i) }
  end

  def self.dehumanize_role(role_value)
    ToolMember.member_roles[role_value]
  end

  def self.dehumanize_roles(role_values)
    role_values.uniq.collect { |role| MembershipHelper.dehumanize_role(role) }
  end
end
