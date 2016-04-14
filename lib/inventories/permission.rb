module Inventories
  class Permission
    attr_reader :inventory
    attr_reader :user

    def initialize(inventory:, user:)
      @inventory = inventory
      @user = user
    end

    def role
      member.try(:role)
    end

    def role=(role)
      return unless ROLES.include? role

      member = inventory.members.find_or_create_by(user: user)
      return if member.role == role

      member.role = role
      member.save!
      notify_user_for_access_granted(role: role)
      reset_member
      role
    end

    def access_request
      inventory.access_requests.where(user: user).first
    end

    def accept
      request = access_request
      return false unless request
      self.role = request.role
      request.destroy!
      reset_member
    end

    def deny
      request = access_request
      return false unless request
      request.destroy!
      reset_member
    end

    def revoke
      membership = member
      membership.destroy!
      reset_member
    end

    def available_roles
      ROLES-[role]
    end

    def request_access(role:)
      request = InventoryAccessRequest.new(inventory: inventory, user: user, role: role)
      return request unless request.save

      InventoryAccessRequestNotificationWorker.perform_async(request.id)
      request
    end

    private
    ROLES = ['facilitator', 'participant']

    def member
      @participant ||= inventory.members.where(user: user).first
    end

    def reset_member
      @participant = nil
    end

    ROLES_TO_NOT_SEND_GRANTED_NOTIFICATION = [:participant]

    def notify_user_for_access_granted(role:)
      return if ROLES_TO_NOT_SEND_GRANTED_NOTIFICATION.include? role.to_sym
      InventoryAccessGrantedNotificationWorker.perform_async(inventory.id, user.id, role) 
    end
  end
end
