require 'spec_helper'

describe WalkThrough::Container do
  let(:subject) { WalkThrough::Container }

  it 'requires a title' do
    container = subject.create
    expect(container.errors_on(:title)).not_to be_empty
  end

  it 'can have multiple slides' do
    container = subject.new(title: "test")
    image_slide = WalkThrough::ImageSlide.create
    html_slide  = WalkThrough::HtmlSlide.create

    container.slides 
  end
end
