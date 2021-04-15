class AddOrderToSeasons < ActiveRecord::Migration[6.0]
  def change
    add_column :seasons, :order, :integer, null: false
  end
end
