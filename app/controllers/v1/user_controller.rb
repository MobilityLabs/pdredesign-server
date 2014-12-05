class V1::UserController < ApplicationController
  before_action :authenticate_user!, except: [:create, :reset, :request_reset]

  def show
    render partial: 'v1/shared/user', locals: { user: current_user }
  end

  def create
    @user                  = User.new(user_params)
    @user.role             = params[:role] || :member
    @user.district_ids     = extract_ids_from_params(:district_ids)
    @user.organization_ids = extract_ids_from_params(:organization_ids)

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
    %w(district_ids organization_ids).each do |key|
      next unless update_params.keys.include?(key)
      update_params[key] = extract_ids_from_params(key)
    end

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
    if user.errors.present?
      return render_errors(user.errors)
    else
      sign_in(:user, user)
      render nothing: true
    end
  end

  def request_reset
    user = User.find_by(email: params[:email].downcase)

    render_errors("Email doesn't exist") and return unless user
    user.update(reset_password_token: hash, 
                reset_password_sent_at: Time.now)

    PasswordResetNotificationWorker.perform_async(user.id)
    render nothing: true
  end

  private

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
              :organization_ids)
  end
end
