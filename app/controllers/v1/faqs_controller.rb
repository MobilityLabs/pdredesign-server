class V1::FaqsController < ApplicationController
  def index
    @questions = Faq::Question.all 
  end
end
