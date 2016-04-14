module Inventories
  class MemberFromInvite
    attr_reader :invite

    def initialize(invite)
      @invite = invite
    end

    def execute
      user = create_or_update_user
      update_user_id(user)
      create_member
      set_permission
    end

    private
    delegate :inventory, to: :invite

    def update_user_id(user)
      invite.user_id = user.id
      invite.save
    end

    def create_member
      InventoryMember.find_or_create_by(
        inventory_id: inventory.id,
        user_id:       user_found.id)
    end

    def create_or_update_user
      user = if user_found
        update_user(user_found)
      else
        create_user
      end
      ensure_user_district(user)
      user
    end

    def update_user(user)
      user.team_role = invite.team_role
      user.save
      return user
    end

    def ensure_user_district(user)
      user.ensure_district(district: inventory.district)
    end

    def create_user
      User.create!(first_name:   invite.first_name,
                   last_name:    invite.last_name,
                   email:        invite.email,
                   password:     generate_password,
                   team_role:    invite.team_role)
    end

    def user_found
      @user_found = User.find_by(email: invite.email)
    end

    def generate_password
      SecureRandom.hex(5)
    end

    def set_permission
      invite.role = 'facilitator' if invite.user.network_partner?
      return unless invite.role
      ap = Inventories::Permission.new(inventory: inventory, user: invite.user)
      ap.role= invite.role
    end
  end
end
