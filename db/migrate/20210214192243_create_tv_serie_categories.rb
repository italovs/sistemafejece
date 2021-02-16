class CreateTvSerieCategories < ActiveRecord::Migration[6.0]
  def change
    create_table :tv_serie_categories do |t|
      t.references :tv_serie, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true

      t.timestamps
    end
  end
end
