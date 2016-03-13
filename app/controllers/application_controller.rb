class ApplicationController < ActionController::Base
  include ScoreQuery
  include RenderStatus
  include ExtractIds

  protect_from_forgery with: :null_session

  layout nil
  respond_to :json

  after_filter :set_csrf_cookie_for_ng
  before_filter :masquerade_user!

  def set_csrf_cookie_for_ng
    cookies['XSRF-TOKEN'] = form_authenticity_token if protect_against_forgery?
  end
    
  protected
  def verified_request?
    super || form_authenticity_token == request.headers['X-XSRF-TOKEN']
  end

end
