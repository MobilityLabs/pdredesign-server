class AddDistrictId < ActiveRecord::Migration
  def change
    add_column :tools, :district_id, :integer
  end
end
