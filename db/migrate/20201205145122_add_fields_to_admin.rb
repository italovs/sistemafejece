class AddFieldsToAdmin < ActiveRecord::Migration[6.0]
  def change
    add_column :admins, :name, :string
    add_column :admins, :about, :string
  end
end
