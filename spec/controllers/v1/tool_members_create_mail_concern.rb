shared_examples_for 'a created tool member with a specific tool' do |tool_sym|
  let(:user) {
    create(:user)
  }

  let(:candidate) {
    create(:user)
  }

  let(:tool) {
    create(tool_sym)
  }

  let!(:tool_member) {
    create(:tool_member, :as_facilitator, tool: tool, user: user)
  }

  let(:notification_worker) {
    case tool_sym
      when :assessment
        AccessGrantedNotificationWorker
      when :inventory
        InventoryAccessGrantedNotificationWorker
      when :analysis
        AnalysisAccessGrantedNotificationWorker
      else
        nil
    end
  }

  context 'when the entity to be created is valid (uppercase tool type)' do
    before(:each) do
      sign_in user
      post :create, params: {
        tool_member: {
          tool_type: tool.class.to_s.upcase,
          tool_id: tool.id,
          roles: [ToolMember.member_roles[:participant]],
          user_id: candidate.id
        }
      }
    end

    it {
      is_expected.to respond_with(:created)
    }

    it {
      expect(ToolMember.where(tool: tool, user: candidate).size).to eq 1
    }

    it {
      expect(notification_worker.jobs.size).to eq 1
    }

    it {
      expect(notification_worker.jobs.first['args'][0]).to eq tool.id
    }

    it {
      expect(notification_worker.jobs.first['args'][1]).to eq candidate.id
    }

    it {
      expect(notification_worker.jobs.first['args'][2]).to eq 'participant'
    }
  end

  context 'when the entity to be created is valid (lowercase tool type)' do
    before(:each) do
      sign_in user
      post :create, params: {
        tool_member: {
          tool_type: tool.class.to_s.downcase,
          tool_id: tool.id,
          roles: [ToolMember.member_roles[:participant]],
          user_id: candidate.id
        }
      }
    end

    it {
      is_expected.to respond_with(:created)
    }

    it {
      expect(ToolMember.where(tool: tool, user: candidate).size).to eq 1
    }

    it {
      expect(notification_worker.jobs.size).to eq 1
    }

    it {
      expect(notification_worker.jobs.first['args'][0]).to eq tool.id
    }

    it {
      expect(notification_worker.jobs.first['args'][1]).to eq candidate.id
    }

    it {
      expect(notification_worker.jobs.first['args'][2]).to eq 'participant'
    }
  end
end
