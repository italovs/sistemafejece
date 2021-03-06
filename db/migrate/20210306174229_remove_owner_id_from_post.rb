class RemoveOwnerIdFromPost < ActiveRecord::Migration[6.0]
  def change
    remove_column :posts, :owner_id
    add_column :tv_series, :owner_id, :integer
    add_column :post_categories, :owner_id, :integer
  end
end
