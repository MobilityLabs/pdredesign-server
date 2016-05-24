module Link
  class InventoryParticipant
    attr_reader :inventory

    def initialize(inventory, *_)
      @inventory = inventory
    end

    def execute
      return nil if draft?

      {dashboard: dashboard_link, report: report_link}

    end

    def dashboard_link
      {title: 'View Dashboard', active: true, type: :dashboard}
    end

    def report_link
      {title: 'View Report', active: true, type: :report}
    end

    def draft?
      inventory.status == :draft
    end
  end
end