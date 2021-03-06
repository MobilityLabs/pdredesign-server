# == Schema Information
#
# Table name: prospective_users
#
#  id           :integer          not null, primary key
#  email        :string(255)      default(""), not null
#  district     :string(255)
#  team_role    :string(255)
#  name         :string(255)
#  ip_address   :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#  ga_dimension :string(255)
#

require 'spec_helper'

describe ProspectiveUser do
  let(:subject) { ProspectiveUser }

  context '#email' do
    it 'valid email' do  
      pu = subject.new(email: 'some_email@google.com', ip_address: '000.000.000.000')
      expect(pu.valid?).to eq(true)
    end

    it 'invalid email' do
      pu = subject.new(email: 'xy@#$@!!!@google.com', ip_address: '000.000.000.000')
      expect(pu.valid?).to eq(false)
      expect(pu.errors[:email]).to_not be_nil
    end

    it 'doenst allow duplicate emails' do
      subject.create(email: 'some_email@google.com', ip_address: '000.000.000.000')
      pu = subject.new(email: 'some_email@google.com', ip_address: '000.000.000.000')
      expect(pu.valid?).to eq(false)
    end
  end
end
