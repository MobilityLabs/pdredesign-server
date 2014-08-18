class V1::CategoriesController < ApplicationController
  def index
    @categories = Category.all
  end
end
