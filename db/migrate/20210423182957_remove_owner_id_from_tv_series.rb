class RemoveOwnerIdFromTvSeries < ActiveRecord::Migration[6.0]
  def change
    remove_column :tv_series, :owner_id, :integer
  end
end
