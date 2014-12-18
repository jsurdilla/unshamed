class CreateJournals < ActiveRecord::Migration
  def change
    create_table :journals do |t|
      t.references :user
      t.string :title
      t.text :body
      t.string :status

      t.timestamps

      t.foreign_key :users, column: :user_id
    end
  end
end
