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
      user.tap do
        user.districts << invite.assessment.district
        user.save
      end
    end

    def create_user
      User.create!(first_name:   invite.first_name,
                   last_name:    invite.last_name,
                   email:        invite.email,
                   password:     generate_password,
                   district_ids: invite.assessment.district_id)
    end

    def user_found
      @user_found = User.find_by(email: invite.email)
    end

    def generate_password
      SecureRandom.hex[0..9]
    end

  end
end
