class AddOwnerIdToTvSeries < ActiveRecord::Migration[6.0]
  def change
    add_reference :tv_series, :owner, foreign_key: { to_table: :junior_enterprises }
  end
end
