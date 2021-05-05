class AddCollumnsToPost < ActiveRecord::Migration[6.0]
  def change
    remove_column :tv_series, :is_admin
    remove_column :post_categories, :owner_id
    remove_column :post_categories, :is_admin
  end
end
