module Invitation
  class InsertFromInvite
    attr_reader :invite
    def initialize(invite)
      @invite = invite
    end

    def execute
      user = create_or_update_user
      update_user_id(user)
      create_participant
      set_permission
    end

    private
    def update_user_id(user)
      invite.user_id = user.id
      invite.save
    end

    def create_participant
      Participant.find_or_create_by(
        assessment_id: invite.assessment.id,
        user_id:       user_found.id)
    end

    def create_or_update_user
      if user_found
        update_user(user_found)
      else
        create_user
      end
    end

    def update_user(user)
      add_district_to_user(user)
      user.update_column(:team_role, invite.team_role)
      return user
    end

    def add_district_to_user(user)
      unless district_member?(user)
        user.tap do
          user.districts << invite.assessment.district 
          user.save
        end
      end
    end

    def district_member?(user)
      user.district_ids.include?(invite.assessment.district_id)
    end

    def create_user
      User.create!(first_name:   invite.first_name,
                   last_name:    invite.last_name,
                   email:        invite.email,
                   password:     generate_password,
                   team_role:    invite.team_role,
                   district_ids: invite.assessment.district_id)
    end

    def user_found
      @user_found = User.find_by(email: invite.email)
    end

    def generate_password
      SecureRandom.hex[0..9]
    end

    def set_permission
      invite.role = 'facilitator' if invite.user.network_partner?
      if invite.role
        ap = Assessments::Permission.new(invite.assessment)
        ap.add_level(invite.user, invite.role)
      end
    end

  end
end
