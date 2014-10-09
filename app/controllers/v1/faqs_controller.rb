class V1::FaqsController < ApplicationController
  def index
    @questions = Faq::Question.includes(:category).all 
  end
end
