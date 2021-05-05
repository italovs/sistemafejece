class RemoveOwnerIdFromPost < ActiveRecord::Migration[6.0]
  def change
    add_column :post_categories, :owner_id, :integer
  end
end
