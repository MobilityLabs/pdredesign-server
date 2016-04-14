# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default("")
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  role                   :string(255)
#  team_role              :string(255)
#  admin                  :boolean          default(FALSE)
#  first_name             :string(255)
#  last_name              :string(255)
#  twitter                :string(255)
#  avatar                 :string(255)
#  ga_dimension           :string(255)
#

require 'spec_helper'

describe User do
  it { is_expected.to validate_presence_of :first_name }
  it { is_expected.to validate_presence_of :last_name }

  describe '#email' do
    let(:user) { FactoryGirl.create(:user, email: 'SomeEmail@stuff.com') }

    it 'retrieves the supplied email in lowercase' do
      expect(user.email).to eq('someemail@stuff.com')
      expect(user[:email]).to eq('someemail@stuff.com')
    end
  end
  describe '#avatar' do
    let(:user) { FactoryGirl.create(:user) }
    it 'returns a default user avatar' do
      expect(user.avatar).to match('images/default.png')
    end
  end

  describe '#network_partner?' do
    context 'when the user is a network partner' do
      let(:user) { FactoryGirl.create(:user, role: :network_partner) }
      it 'returns true' do
        expect(user.network_partner?).to be true
      end
    end

    context 'when the user is not a network partner' do
      let(:user) { FactoryGirl.create(:user, role: :district_member) }
      it 'returns false' do
        expect(user.network_partner?).to be false
      end
    end
  end

  describe '#district_member?' do
    context 'when the user is a district member' do
      let(:user) { FactoryGirl.create(:user, role: :district_member) }
      it 'returns true' do
        expect(user.district_member?).to be true
      end
    end

    context 'when the user is a network partner' do
      let(:user) { FactoryGirl.create(:user, role: :network_partner) }
      it 'returns false' do
        expect(user.district_member?).to be false
      end
    end
  end

  describe '#role' do
    let(:user) { FactoryGirl.create(:user, role: :other) }

    it 'returns district_member when the user is not a network_partner' do
      expect(user.role).to eq(:district_member)
    end
  end

  describe '#twitter' do
    context "when the user's Twitter handle is updated" do
      let!(:user) { FactoryGirl.create(:user, :with_district, twitter: 'foobar') }

      before(:each) do
        TwitterAvatarWorker.jobs.clear
        user.update(twitter: 'new_name')
      end

      it 'enqueues the avatar update job' do
        expect(TwitterAvatarWorker.jobs.count).to eq 1
      end
    end

    context "when the user's Twitter handle is not updated" do
      let(:user) { FactoryGirl.create(:user, :with_district, twitter: 'foobar') }

      before(:each) do
        TwitterAvatarWorker.jobs.clear
      end

      it 'does not enqueue the avatar update job ' do
        expect(TwitterAvatarWorker.jobs.count).to eq 0
      end
    end
  end

  describe '#name' do
    let(:user) { FactoryGirl.create(:user, first_name: 'John', last_name: 'Doe') }
    context 'with both a first and last name' do
      it 'returns a full name' do
        expect(user.name).to eq('John Doe')
      end
    end
  end

  describe '#ensure_district' do
    let(:district) { FactoryGirl.create(:district) }
    let(:user) { FactoryGirl.create(:user) }

    context 'ensuring a single district' do
      before(:each) do
        user.ensure_district(district: district)
      end

      it do
        expect(user.districts).to include district
      end
    end

    context 'ensuring same district twice' do
      before(:each) do
        user.ensure_district(district: district)
        user.ensure_district(district: district)
      end

      it 'does not duplicate the district' do
        expect(user.districts.where(id: district.id).count).to be 1
      end
    end

    context 'ensuring different districts' do
      let(:another_district) { FactoryGirl.create(:district) }

      before(:each) do
        user.ensure_district(district: district)
        user.ensure_district(district: another_district)
      end

      it do
        expect(user.districts).to have(2).items
      end

      it 'adds first district' do
        expect(user.districts).to include district
      end

      it 'adds second district' do
        expect(user.districts).to include another_district
      end
    end
  end
end
