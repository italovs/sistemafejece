class AddCollumnsToTvSerie < ActiveRecord::Migration[6.0]
  def change
    add_column :tv_series, :is_admin, :boolean
  end
end
