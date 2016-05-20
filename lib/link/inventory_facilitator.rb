module Link
  class InventoryFacilitator
    attr_reader :inventory, :user

    def initialize(inventory, user)
      @inventory = inventory
      @user = user
    end

    def execute
      generate_links
    end

    private
    def generate_links
      if draft?
        {finish: finish_link}
      else
        {dashboard: dashboard_link, report: report_link}
      end
    end

    def finish_link
      {title: 'Finish & Assign', active: true, type: :finish}
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