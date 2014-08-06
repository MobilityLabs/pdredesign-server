class V1::OrganizationsController < ApplicationController
  before_action :authenticate_user!

  def create
    @organization = Organization.new(organization_params)

    unless @organization.save
      @errors = @organization.errors
      render 'v1/shared/errors' , errors: @errors, status: 422
    end
  end

  def update
    @organization = find_organization
    update_params = organization_params
    @organization.update(update_params)
  end

  def search
    @results = Organization.search(organization_params[:query])
  end

  def show
    @organization = Organization.find(params[:id])
  end

  private
  def find_organization
    Organization.find(params[:id])
  end

  def organization_params
    params.permit(:query, :name, :logo, :category_ids=>[])
  end
end
