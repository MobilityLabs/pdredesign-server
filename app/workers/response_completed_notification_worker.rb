class ResponseCompletedNotificationWorker
  include ::Sidekiq::Worker

  def perform(response_id)
    response = find_response(response_id)

    ResponsesMailer
      .submitted(response)
      .deliver_now
  end

  private
  def find_response(response_id)
    Response.find(response_id)
  end

end
