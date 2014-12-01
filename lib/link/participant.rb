module Link
  class Participant

    attr_reader :assessment
    delegate :fully_complete?, to: :assessment

    def initialize(assessment, *args)
      @assessment = assessment
    end

    def execute
      { action: action, report: report }
    end

    private
    def action
      return response unless consensus?
      consensus
    end

    def response
      {title: 'Complete Survey', active: true, type: :response}
    end

    def report
      {title: 'Report', active: fully_complete?, type: :report}
    end

    def consensus
      {title: 'Consensus', active: fully_complete?, type: :consensus}
    end

    def consensus?
      assessment.status == :consensus
    end

  end
end
