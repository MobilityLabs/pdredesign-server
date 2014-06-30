module Invitation
  class InsertFromInvite
    attr_reader :invite
    def initialize(invite)
      @invite = invite
    end

    def execute
      create_or_update_user
    end

    private
    def create_or_update_user
      found_user = User.find_by(email: invite.email)
      return update_user(found_user) if(found_user)

      create_user
    end

    def update_user(user)
      user.tap do
        user.districts << invite.assessment.district
        user.save
      end
    end

    def create_user
      User.create!  first_name:   invite.first_name,
                    last_name:    invite.last_name,
                    email:        invite.email,
                    password:     generate_password,
                    district_ids: invite.assessment.district_id
    end

    def generate_password
      SecureRandom.hex[0..9]
    end

  end
end
