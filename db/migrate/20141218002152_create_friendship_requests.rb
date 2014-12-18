class CreateFriendshipRequests < ActiveRecord::Migration
  def change
    create_table :friendship_requests do |t|
      t.references :user
      t.integer :receiver_id

      t.string :state

      t.foreign_key :users, column: :user_id
      t.foreign_key :users, column: :receiver_id

      t.timestamps
    end
  end
end
