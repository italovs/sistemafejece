class AddCollumnsToPostCategory < ActiveRecord::Migration[6.0]
  def change
    add_column :post_categories, :owner_id, :integer
    add_column :post_categories, :is_admin, :bool
  end
end
