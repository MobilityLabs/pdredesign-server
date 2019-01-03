# == Schema Information
#
# Table name: tool_members
#
#  tool_type   :string
#  tool_id     :integer
#  role        :integer
#  user_id     :integer          not null
#  invited_at  :datetime
#  reminded_at :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  response_id :integer
#  id          :integer          not null, primary key
#  roles       :integer          default([]), is an Array
#

require 'spec_helper'

describe ToolMember do
  it {
    is_expected.to belong_to :user
  }

  it {
    is_expected.to belong_to :tool
  }

  context 'when no roles are specified' do
    let(:tool_member) {
      build(:tool_member)
    }

    before(:each) do
      tool_member.save
    end

    it {
      expect(tool_member.errors[:roles]).to include 'At least one role must be specified.'
    }
  end

  context 'when more roles are added than are legally supported' do
    let(:tool_member) {
      build(:tool_member, roles: [ToolMember.member_roles.values.first,
                                  ToolMember.member_roles.values.first,
                                  ToolMember.member_roles.values.second])
    }

    before(:each) do
      tool_member.save
    end

    it {
      expect(tool_member.errors[:roles]).to include 'You may not add more than 2 roles.'
    }
  end

  context 'when invalid roles are added' do
    let(:tool_member) {
      build(:tool_member, roles: [-1, -2])
    }

    before(:each) do
      tool_member.save
    end

    it {
      expect(tool_member.errors[:roles]).to include 'Invalid role number: -1'
    }

    it {
      expect(tool_member.errors[:roles]).to include 'Invalid role number: -2'
    }
  end

  context 'when a user is a member of a tool' do
    context 'when the user is a participant' do
      let(:user) {
        create(:user)
      }

      let(:tool_member) {
        create(:tool_member, :as_inventory_member, :as_participant, user: user)
      }

      it 'allows the user to be added as a facilitator' do
        tool_member.roles << ToolMember.member_roles[:facilitator]
        expect { tool_member.save! }.to_not raise_error
      end

      it 'does not allow persistence of another participant value' do
        tool_member.roles << ToolMember.member_roles[:participant]
        expect { tool_member.save! }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context 'when the user is a facilitator' do
      let(:user) {
        create(:user)
      }

      let(:tool_member) {
        create(:tool_member, :as_inventory_member, :as_facilitator, user: user)
      }

      it 'allows the user to be added as a participant' do
        tool_member.roles << ToolMember.member_roles[:participant]
        expect { tool_member.save! }.to_not raise_error
      end
    end
  end
end
