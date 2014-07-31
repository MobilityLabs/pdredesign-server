class V1::UserController < ApplicationController
  before_action :authenticate_user!, except: [:create, :reset, :request_reset]

  def show
    render partial: 'v1/shared/user', locals: { user: current_user }
  end

  def create
    @user      = User.new(user_params)
    @user.role = params[:role] || :member
    @user.district_ids = district_ids

    if @user.save
      send_notification_email
      render status: 200, nothing: true
    else
      render_errors(@user.errors)
    end
  end

  def update
    @user = current_user

    update_params = user_params
    update_params[:district_ids] = district_ids

    if current_user.update(update_params)
      render partial: 'v1/shared/user', locals: { user: current_user }
    else
      render_errors(@user.errors)
    end
  end

  def reset
    user = find_by_token(params[:token])
    status(401) and return unless user

    reset_password(user, params[:password])
    render_errors(user.errors) and return if user.errors.present?

    render nothing: true
  end

  def request_reset
    user = User.find_by(email: params[:email])

    status(200) and return unless user
    user.update(reset_password_token: hash, 
                reset_password_sent_at: Time.now)

    PasswordResetNotificationWorker.perform_async(user.id)
    render nothing: true
  end

  private
  def district_ids 
    return '' unless params[:district_ids]
    params[:district_ids].split(",")
  end

  def hash
    SecureRandom.hex[0..9]
  end

  def render_errors(errors)
    @errors = errors
    render 'v1/shared/errors', status: 422
  end

  def reset_password(user, password)
    user.reset_password_token   = nil
    user.reset_password_sent_at = nil
    user.password = params[:password]
    user.save
  end

  def find_by_token(token)
    User.find_by(reset_password_token: token)
  end

  def send_notification_email
    SignupNotificationWorker.perform_async(@user.id)
  end
  
  def user_params
    params
      .permit(:first_name,
              :last_name,
              :email,
              :district_ids,
              :twitter,
              :team_role,
              :role,
              :password,
              :password_confirmation,
              :organizations => :categories)
  end
end
