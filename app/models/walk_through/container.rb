class WalkThrough::Container < ActiveRecord::Base
  validates :title, presence: true

  has_many :slides, dependent: :destroy
  has_many :walk_through_views, dependent: :destroy, class: WalkThrough::View
end
