class WalkThrough::View < ActiveRecord::Base
  belongs_to :walk_through_container, class: WalkThrough::Container
  belongs_to :user
end
