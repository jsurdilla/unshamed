class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.text :body
      t.string :feeling

      t.integer :author_id

      t.timestamps
    end
  end
end
