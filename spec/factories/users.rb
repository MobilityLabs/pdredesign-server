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

FactoryGirl.define do
  factory :user do
    email { Faker::Internet.safe_email }
    password { Faker::Internet.password(12) }
    role  :district_member
    admin false
    first_name 'Example'
    last_name 'User'
  end

  trait :with_district do
    transient do
      districts 1
    end

    after(:create) do |user, evaluator|
      user.districts = FactoryGirl.create_list(:district, evaluator.districts)
    end
  end

  trait :with_network_partner_role do
    role :network_partner
  end

  trait :with_facilitator_role do
    role :facilitator
  end

  trait :without_role do
    role nil
  end
end