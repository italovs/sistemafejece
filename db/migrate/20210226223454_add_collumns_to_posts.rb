class AddCollumnsToPosts < ActiveRecord::Migration[6.0]
  def change
    add_column :posts, :votes, :integer
    add_column :posts, :sum_votes, :integer
    add_column :posts, :kind, :integer
    remove_column :posts, :rating
  end
end
