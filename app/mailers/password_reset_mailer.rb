class PasswordResetMailer < ApplicationMailer

  def reset(user)
    @token      = user.reset_password_token
    @reset_link = reset_link(@token)
    mail(to: user.email)
  end

  private
  def reset_link(token)
    "#{ENV['BASE_URL']}/#/reset/#{token}"
  end

end
