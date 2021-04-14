class AddOrderToSeasonPosts < ActiveRecord::Migration[6.0]
  def change
    add_column :season_posts, :order, :integer, null: false
  end
end
