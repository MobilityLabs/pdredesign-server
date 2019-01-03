class V1::ProspectiveUsersController < ApplicationController
  def create
    user = create_prospective_user(allowed_params)
    user.valid? ? render_valid : render_errors(user)
  end

  private
  def render_valid
    head :ok
  end

  def render_errors(record)
    render :create, status: :unprocessable_entity, locals: { errors: record.errors }
  end

  def allowed_params
    params.permit(:email, :ip_address)
  end

  def create_prospective_user(params)
    ProspectiveUser.create(params)
  end
end
