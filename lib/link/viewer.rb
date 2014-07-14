module Link
  class Viewer

    attr_reader :assessment, :user
    delegate :fully_complete?, :viewer?,  to: :assessment

    def initialize(assessment, user)
      @assessment = assessment
      @user       = user
    end

    def execute
      { report: report, access: access }
    end

    private
    def report
      {title: 'Report', active: consensus?, type: :report}
    end

    def access
      return request unless viewer?(user)
      pending
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
