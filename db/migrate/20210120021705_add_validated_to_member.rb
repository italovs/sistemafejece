class AddValidatedToMember < ActiveRecord::Migration[6.0]
  def change
    add_column :members, :validated, :boolean
  end
end
