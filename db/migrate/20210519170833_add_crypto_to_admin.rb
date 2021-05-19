class AddCryptoToAdmin < ActiveRecord::Migration[6.0]
  def change
    add_column :admins, :email_ciphertext, :text
    add_column :admins, :email_bidx, :string
    remove_column :admins, :email

    add_column :admins, :name_ciphertext, :text
    add_column :admins, :name_bidx, :string
    remove_column :admins, :name
    add_column :admins, :about_ciphertext, :text
    add_column :admins, :about_bidx, :string
    remove_column :admins, :about
  end
end
