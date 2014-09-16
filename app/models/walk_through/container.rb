class WalkThrough::Container < ActiveRecord::Base
  has_many :slides, polymorphic: true
end
