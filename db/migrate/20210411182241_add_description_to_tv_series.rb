class AddDescriptionToTvSeries < ActiveRecord::Migration[6.0]
  def change
    add_column :tv_series, :description, :string
  end
end
