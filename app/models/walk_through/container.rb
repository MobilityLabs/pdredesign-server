class WalkThrough::Container < ActiveRecord::Base
  validates :title, presence: true
  has_many :slides, dependent: :destroy
end
