require 'rake'

module DefaultWalkThrough
  def self.create

  end
end

namespace :db do
  desc "Create all default WalkThrough records"
  task :create_default_walk_throughs => :environment do
    ActiveRecord::Base.transaction do
      DefaultWalkThrough::create()
    end
  end
end
