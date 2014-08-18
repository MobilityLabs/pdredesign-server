class ApplicationController < ActionController::Base
  include ScoreQuery
  include RenderStatus
  include ExtractIds

  layout nil
  respond_to :json

  after_filter :set_csrf_cookie_for_ng
  def set_csrf_cookie_for_ng
    cookies['XSRF-TOKEN'] = form_authenticity_token if protect_against_forgery?
  end
    
  protected
  def verified_request?
    super || form_authenticity_token == request.headers['X-XSRF-TOKEN']
  end

end
