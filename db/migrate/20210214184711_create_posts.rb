class CreatePosts < ActiveRecord::Migration[6.0]
  def change
    create_table :posts do |t|
      t.string :name
      t.string :description
      t.string :link
      t.float :rating

      t.timestamps
    end
  end
end
