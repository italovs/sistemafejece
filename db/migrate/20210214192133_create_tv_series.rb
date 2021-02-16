class CreateTvSeries < ActiveRecord::Migration[6.0]
  def change
    create_table :tv_series do |t|
      t.string :name

      t.timestamps
    end
  end
end
