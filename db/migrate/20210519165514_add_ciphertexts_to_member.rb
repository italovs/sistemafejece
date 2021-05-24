class AddCiphertextsToMember < ActiveRecord::Migration[6.0]
  def change
    add_column :members, :name_ciphertext, :text
    add_column :members, :about_ciphertext, :text
    add_column :members, :name_bidx, :string
    add_column :members, :about_bidx, :string

    remove_column :members, :about
    remove_column :members, :name
  end
end
