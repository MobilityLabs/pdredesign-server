class V1::OrganizationsController < ApplicationController
  def search
    @results = Organization.search(organization_params[:query])
  end

  def show
    @organization = Organization.find(params[:id])
  end

  private
  def organization_params
    params.permit(:query)
  end
end
