require 'spec_helper'

describe WalkThrough::View do
  let(:subject) { WalkThrough::View }

  it 'can create a view record for a container' do
    @container = WalkThrough::Container.new(title: "Some title")
    subject.create!(walk_through_container: @container)
  end
end
