module Link
  class Partner

    attr_reader :assessment, :user
    delegate :pending_requests?, :network_partner?, to: :assessment

    def initialize(assessment, user)
      @assessment = assessment
      @user       = user
    end

    def execute
      { access: access}
    end

    private
    def access
      return pending if     pending_requests?(user)
      return request unless network_partner?(user)
    end

    def request
      { title: 'Request Access', type: :request_access }
    end

    def pending
      { title: 'Access Pending', type: :pending }
    end

  end
end
