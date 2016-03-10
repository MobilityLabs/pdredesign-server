class RenameInventoryDistrictsIdsToDistrictid < ActiveRecord::Migration
  def change
    rename_column :inventories, :districts_id, :district_id
  end
end
