class CreateMonthHistories < ActiveRecord::Migration[6.0]
  def change
    create_table :month_histories do |t|
      t.references :post, null: false, foreign_key: true
      t.references :junior_enterprise, null: false, foreign_key: true
      t.integer :uniq_views
      t.integer :views
      t.integer :month
      t.integer :year

      t.timestamps
    end
  end
end
