class ApplicationController < ActionController::Base
  include ScoreQuery

  layout nil
  respond_to :json

  after_filter :set_csrf_cookie_for_ng
  def set_csrf_cookie_for_ng
    cookies['XSRF-TOKEN'] = form_authenticity_token if protect_against_forgery?
  end
    
  protected
  def unauthorized
    status 401
  end

  def not_found
    status 404
  end

  def status(status_code)
    render nothing: true, status: status_code
  end

  def verified_request?
    super || form_authenticity_token == request.headers['X-XSRF-TOKEN']
  end
end
