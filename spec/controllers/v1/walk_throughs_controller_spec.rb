require 'spec_helper'

describe V1::WalkThroughsController do
  render_views

  before :each do
    request.env["HTTP_ACCEPT"] = 'application/json'
  end


  describe '#show' do
    before do
      @container = WalkThrough::Container.create!(title: "example")
    end

    it 'returns a specific walkthrough' do
      get :show, id: @container.id

      expect(json["title"]).to eq("example")
    end

    it 'returns all the slides for this container' do
      image_slide = WalkThrough::ImageSlide.create!
      html_slide  = WalkThrough::HtmlSlide.create!(content: "some content")

      image_slide.image = File.open(Rails.root.join("spec", "fixtures", "files", "logo.png"))
      image_slide.save!

      @container.slides << image_slide
      @container.slides << html_slide

      get :show, id: @container.id
      expect(json["slides"].count).to eq(2)
      expect(json["slides"].first["image"]).to match(/logo\.png/)
      expect(json["slides"].last["content"]).to eq("some content")
    end
  end
end
