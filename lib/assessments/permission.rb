module Assessments
  class Permission

    PERMISSIONS = [:facilitator, :viewer, :partner, :participant]

    attr_reader :assessment

    def initialize(assessment)
      @assessment = assessment
    end

    def possible_roles_permissions(user)
      PERMISSIONS-[get_level(user)]
    end

    def requested
      AccessRequest.where(assessment_id: assessment.id)
    end

    def get_access_request(user)
      AccessRequest.find_by(assessment_id: assessment.id, user_id: user.id)
    end

    def get_level(user)
      return case
        when assessment.facilitator?(user); :facilitator
        when assessment.participant?(user); :participant
        when assessment.network_partner?(user); :network_partner
        when assessment.viewer?(user); :viewer
        end
    end

    def add_level(user, level)
      case level.to_sym
        when :facilitator
          grant_facilitator(assessment, user)
        when :viewer
          grant_viewer(assessment, user)
        when :network_partner
          grant_network_partner(assessment, user)
        else
          return false
      end
      notify_user_for_access_granted(assessment, user, level)
      return true 
    end

    def update_level(user, level)
      unless assessment.owner?(user)
        revoke_level(user)
        add_level(user, level)
      end
    end

    def accept_permission_requested(user)
      ar = get_access_request(user)
      grant_access(ar)
      notify_user_for_access_granted(ar.assessment, ar.user, ar.roles.first)
    end

    def deny(user)
      ar = get_access_request(user)
      ar.destroy
    end

    def revoke_level(user)
      case get_level(user)
        when :facilitator
          assessment.facilitators.delete(user)
        when :viewer
          assessment.viewers.destroy(user)
        when :network_partner
          assessment.network_partners.destroy(user)
        when :participant
          #TODO: should be deleted from participants list?
        assessment.reload
      end

    end

    def self.available_permissions
      # this would be return the available and valid permissions for Assessments
      PERMISSIONS
    end

    def self.request_access(request_options)
      roles = request_options[:roles].class == String ? [request_options[:roles]] : request_options[:roles]
      
      return AccessRequest.create({
        roles: roles, token: SecureRandom.hex[0..9],
        user: request_options[:user], assessment_id: request_options[:assessment_id]
      })
    end

    private
    def grant_access(record)
      record.roles.each do |role|
        send("grant_#{role}", assessment, record.user)
      end

      record.destroy
      true
    end

    def grant_facilitator(assessment, user)
      assessment.facilitators << user
    end

    def grant_viewer(assessment, user)
      assessment.viewers << user   
    end

    def grant_network_partner(assessment, user)
      assessment.network_partners << user
    end

    def grant_participant(assessment, user)
      Participant.create!(assessment: assessment, user: user, invited_at: Time.now)
    end

    def notify_user_for_access_granted(assessment, user, role)
      AccessGrantedNotificationWorker.perform_async(assessment.id, user.id, role)
    end
  end
end