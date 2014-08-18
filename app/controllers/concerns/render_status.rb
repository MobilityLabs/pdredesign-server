module RenderStatus
  extend ActiveSupport::Concern

  def unauthorized
    status 401
  end

  def not_found
    status 404
  end

  def status(status_code)
    render nothing: true, status: status_code
  end

end
