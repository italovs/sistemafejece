class AddFieldsToMember < ActiveRecord::Migration[6.0]
  def change
    add_column :members, :about, :text
    add_reference :members, :junior_enterprise, null: false, foreign_key: true
    add_column :members, :position, :integer
  end
end
