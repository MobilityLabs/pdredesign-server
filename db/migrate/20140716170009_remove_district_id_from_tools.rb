class RemoveDistrictIdFromTools < ActiveRecord::Migration
  def change
      remove_column :tools, :district_id
  end
end
