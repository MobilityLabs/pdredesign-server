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
  def new_user(opts = {})
    User.new(opts)
  end

  context '#avatar' do
    it 'returns a default user avatar' do
      user = new_user() 
      expect(user.avatar).to match('images/default.png')
    end
  end

  context '#network_partner?' do
    it 'returns true when a user is a network partner' do
      user = new_user(role: :network_partner)
      expect(user.network_partner?).to eq(true)

      user.update(role: "network_partner")
      expect(user.network_partner?).to eq(true)

      user.update(role: :district_member)
      expect(user.network_partner?).to eq(false)
    end
  end

  context '#role' do
    it 'returns network_partner when the user is a network_partner' do
      user = new_user(role: :network_partner)
      expect(user.role).to eq(:network_partner)
    end

    it 'returns district_member when the user is not a network_partner' do
      user = new_user(role: :other)
      expect(user.role).to eq(:district_member)
    end
  end

  context '#district_member?' do
    it 'returns true when a user is a district member' do
      user = new_user(role: :district_member)
      expect(user.district_member?).to eq(true)

      user.update(role: "district_member")
      expect(user.district_member?).to eq(true)

      user.update(role: :network_partner)
      expect(user.district_member?).to eq(false)
    end

  end

  context 'simple validations' do
    it 'requires :first_name' do
      active_record_error(new_user, :first_name, "can't be blank")
    end

    it 'requires :last_name' do
      active_record_error(new_user, :last_name, "can't be blank")
    end
  end

  context 'downcase email' do
    it 'downcases the users email' do
      user = new_user(email: 'SomeEmail@stuff.com')
      expect(user.email).to eq('someemail@stuff.com')
      expect(user[:email]).to eq('someemail@stuff.com')
    end
  end
  
  context '#twitter' do
    it 'queues twitter avatar update job when twitter changed' do
      user = Application::create_sample_user(email: 'SomeEmail@stuff.com',
        twitter: 'old_name')

      TwitterAvatarWorker.jobs.clear
      user.update(twitter: 'new_name')
      expect(TwitterAvatarWorker.jobs.count).to eq(1)
    end
    
    it 'does not queue job when twitter is not changed' do
      user = Application::create_sample_user(email: 'SomeEmail@stuff.com',
        twitter: 'old_name')

      TwitterAvatarWorker.jobs.clear

      expect(user.save).to eq(true)
      expect(TwitterAvatarWorker.jobs.count).to eq(0)
    end

  end

  context '#name' do
    it 'returns the users fullname' do
      user = new_user(first_name: 'John', last_name: 'Doe')
      expect(user.name).to eq('John Doe')
    end
  end

end
