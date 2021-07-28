class CreateActualMonths < ActiveRecord::Migration[6.0]
  def change
    create_table :actual_months do |t|
      t.references :post, null: false, foreign_key: true
      t.integer :user_id
      t.boolean :admin
      t.integer :views

      t.timestamps
    end
  end
end
