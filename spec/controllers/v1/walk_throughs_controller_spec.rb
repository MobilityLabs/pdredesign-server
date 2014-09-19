require 'spec_helper'

describe V1::WalkThroughsController do
  render_views

  before :each do
    request.env["HTTP_ACCEPT"] = 'application/json'

    @user = Application::create_user
    sign_in @user
  end

  describe '#viewed' do
    before do
      @container = WalkThrough::Container.create!(title: "example")
    end

    it 'requires a user to track a view' do
      sign_out :user
      post :viewed, walk_through_id: @container.id

      assert_response :unauthorized
    end

    it 'creates a user walk through view record' do
      post :viewed, walk_through_id: @container.id

      record = WalkThrough::View.find_by(container: @container)
      expect(record).not_to be_nil
    end

    it 'does not create duplicate records' do
      WalkThrough::View.create!(container: @container, user: @user)
      post :viewed, walk_through_id: @container.id

      record = WalkThrough::View.where(container: @container, user: @user)
      expect(record.count).to eq(1)
    end
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
