class AddEmailBidxToMembers < ActiveRecord::Migration[6.0]
  def change
    add_column :members, :email_bidx, :string
    add_index :members, :email_bidx, unique: true
  end
end
