module Link
  class Facilitator

    attr_reader :assessment
    def initialize(assessment, *args)
      @assessment = assessment
    end

    def execute
      if draft?
        {finish: finish }
      else
        {consensus: consensus, report: report }.tap do |links|
          links[:dashboard] = dashboard
        end
      end
    end

    private
    def finish
      {title: 'Finish & Assign', active: true, type: :finish}
    end

    def dashboard
      {title: 'Dashboard', active: true, type: :dashboard}
    end

    def consensus
      return new_consensus unless consensus?
      existing_consensus
    end

    def existing_consensus
      {title: 'Consensus', active: true, type: :consensus}
    end

    def new_consensus
      {title: 'Create Consensus', active: true, type: :new_consensus}
    end

    def report
      {title: 'Report', active: consensus?, type: :report}
    end

    def consensus?
      assessment.status == :consensus
    end

    def draft?
      assessment.status == :draft
    end

  end
end
