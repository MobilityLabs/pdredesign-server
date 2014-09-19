class WalkThrough::View < ActiveRecord::Base
  belongs_to :container, class: WalkThrough::Container
  belongs_to :user
end
