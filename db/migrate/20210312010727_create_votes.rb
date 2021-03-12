class CreateVotes < ActiveRecord::Migration[6.0]
  def change
    create_table :votes do |t|
      t.references :post, null: false, foreign_key: true
      t.integer :value
      t.integer :owner
      t.boolean :admin

      t.timestamps
    end
  end
end
