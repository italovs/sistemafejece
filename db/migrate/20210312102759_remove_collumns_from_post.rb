class RemoveCollumnsFromPost < ActiveRecord::Migration[6.0]
  def change
    remove_column :posts, :sum_votes
    remove_column :posts, :votes
  end
end
