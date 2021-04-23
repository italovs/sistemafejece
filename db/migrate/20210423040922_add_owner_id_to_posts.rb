class AddOwnerIdToPosts < ActiveRecord::Migration[6.0]
  def change
    add_reference :posts, :owner, foreign_key: { to_table: :junior_enterprises }
  end
end
