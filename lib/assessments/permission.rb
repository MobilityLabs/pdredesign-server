module Assessments
  class Permission

    attr_reader :assessment

    def initialize(assessment)
      @assessment = assessment
    end

    def requested
      AccessRequest.where(assessment_id: assessment.id)
    end

    def user_level(user)
      return case
        when assessment.facilitator?(user); :facilitator
        when assessment.participant?(user); :participant
        when assessment.network_partner?(user); :facilitator
        when assessment.viewer?(user); :viewer
        end
    end

    def accept_permission_requested(user)
      ar = AccessRequest.find_by(assessment_id: assessment.id, user_id: user.id)
      grant_access(ar)
    end

    def self.available_permissions
      # this would be return the available and valid permissions for Assessments
      [:facilitator, :viewer, :partner, :participant]
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
  end
end