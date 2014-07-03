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
#  invitation_token       :string(255)
#  invitation_created_at  :datetime
#  invitation_sent_at     :datetime
#  invitation_accepted_at :datetime
#  invitation_limit       :integer
#  invited_by_id          :integer
#  invited_by_type        :string(255)
#  first_name             :string(255)
#  last_name              :string(255)
#  twitter                :string(255)
#  avatar                 :string(255)
#

require 'spec_helper'

describe User do
  def new_user(opts = {})
    User.new(opts)
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

  context '#has_districts?' do  
    it 'errors when not admin' do  
      active_record_error(new_user, :district_ids, "You must select at least one school district.")
    end

    it 'does not error when admin' do
      no_active_record_error(new_user(admin: true), :district_ids, "You must select at least one school district.")
    end
  end

end
