class V1::DataEntriesController < ApplicationController
  include SharedInventoryFetch
  before_action :authenticate_user!, except: :index
  before_action :inventory, except: [:index, :destroy, :restore]

  def index
    @data_entries = data_entries

    respond_to do |format|
      format.json { render template: 'v1/data_entries/index' }
      format.csv  { render csv: 'data_entries', template: 'v1/data_entries/index' }
    end
  end

  def show
    @data_entry = data_entries.find(params[:id])
    authorize_action_for @data_entry
    render template: 'v1/data_entries/show'
  end

  def create
    @data_entry = inventory.data_entries.new(data_entry_params)
    authorize_action_for @data_entry

    if @data_entry.save
      render template: 'v1/data_entries/show', status: 201
    else
      render_error
    end
  end

  def update
    @data_entry = inventory.data_entries.find(params[:id])
    authorize_action_for @data_entry
    
    if @data_entry.update(data_entry_params)
      render template: 'v1/data_entries/show', status: 200
    else
      render_error
    end
  end

  def destroy
    @data_entry = Inventory.find(params[:inventory_id]).data_entries.find(params[:id])
    authorize_action_for @data_entry

    @data_entry.destroy

    head :no_content
  end
  
  def restore
    @data_entry = Inventory.find(params[:inventory_id]).data_entries.with_deleted.find(params[:id])
    authorize_action_for @data_entry

    @data_entry.restore(recursive: true)

    head :no_content
  end
  
  private
  def data_entries
    if inventory.facilitator?(current_user)
      inventory.data_entries.with_deleted
    else
      inventory.data_entries
    end
  end

  def render_error
    @errors = @data_entry.errors
    render 'v1/shared/errors', status: 422
  end

  def data_entry_params
    params.permit(
      :name,
      general_data_question_attributes: [
        :id,
        :data_type,
        :point_of_contact_name,
        :point_of_contact_department,
        :data_capture
      ],
      data_entry_question_attributes: [
        :id,
        :who_enters_data,
        :how_data_is_entered,
        :when_data_is_entered
      ],
      data_access_question_attributes: [
        :id,
        :data_storage,
        :who_access_data,
        :how_data_is_accessed,
        :why_data_is_accessed,
        :notes
      ]
    )
  end
end
