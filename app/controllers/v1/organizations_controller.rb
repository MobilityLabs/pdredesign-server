class V1::OrganizationsController < ApplicationController
  before_action :authenticate_user!

  def create
    authorize_action_for Organization
    @organization = Organization.new(organization_params)

    render_errors(@organization.errors) unless @organization.save
  end

  def update
    @organization = find_organization
    authorize_action_for @organization

    @organization.update(organization_params)
    render_errors(@organization.errors) unless @organization.save
  end

  def search
    @results = Organization.search(params[:query])
  end

  def show
    @organization = find_organization
  end

  private
  def render_errors(errors)
    @errors = errors
    render 'v1/shared/errors', status: 422
  end

  def find_organization
    Organization.find(params[:id])
  end

  def organization_params
    params.permit(:name, :logo, :category_ids=>[])
  end
end
