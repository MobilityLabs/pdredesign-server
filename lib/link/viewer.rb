module Link
  class Viewer

    attr_reader :assessment, :user
    delegate :pending_requests?, :fully_complete?, :viewer?,  to: :assessment

    def initialize(assessment, user)
      @assessment = assessment
      @user       = user
    end

    def execute
      {access: access, report: report}
    end

    private
    def report
      {title: 'Report', active: consensus?, type: :report}
    end

    def access
      return pending if pending_requests?(user)
      return request unless viewer?(user)
    end

    def request
      { title: 'Request Access', type: :request_access, active: true}
    end

    def pending
      { title: 'Access Pending', type: :pending, active: false }
    end

    def consensus?
      assessment.status == :consensus
    end

  end
end
