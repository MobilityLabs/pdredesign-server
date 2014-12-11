module Link
  class Facilitator

    attr_reader :assessment
    delegate :fully_complete?, to: :assessment

    def initialize(assessment, *args)
      @assessment = assessment
    end

    def execute
      if draft?
        {finish: finish }
      elsif fully_complete?
        {consensus: consensus, report: report, dashboard: dashboard }
      elsif consensus?
        {consensus: consensus, dashboard: dashboard }
      elsif participant?
        { response: response, consensus: consensus, dashboard: dashboard}
      else
        {consensus: consensus, dashboard: dashboard }
      end
    end

    private
    def finish
      {title: 'Finish & Assign', active: true, type: :finish}
    end

    def dashboard
      {title: 'View Dashboard', active: true, type: :dashboard}
    end

    def consensus
      return new_consensus unless consensus?
      existing_consensus
    end

    def response
      {title: 'Complete Survey', active: true, type: :response}
    end

    def existing_consensus
      {title: 'Consensus', active: true, type: :consensus}
    end

    def new_consensus
      {title: 'Create Consensus', active: true, type: :new_consensus}
    end

    def report
      {title: 'View Report', active: consensus?, type: :report}
    end

    def consensus?
      assessment.status == :consensus
    end

    def participant?
      assessment.participant?(assessment.user)
    end

    def draft?
      assessment.status == :draft
    end

  end
end
