class V1::FaqsController < ApplicationController
  def index
    @categories = Faq::Category.all
  end
end
