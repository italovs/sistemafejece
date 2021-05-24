class AddEmailCiphertextToMembers < ActiveRecord::Migration[6.0]
  def change
    add_column :members, :email_ciphertext, :text
  end
end
