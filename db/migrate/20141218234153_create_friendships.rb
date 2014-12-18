class CreateFriendships < ActiveRecord::Migration
  def change
    create_table :friendships do |t|
      t.references :user
      t.integer :friend_id
      t.references :friendship_request

      t.foreign_key :users, column: :user_id
      t.foreign_key :users, column: :friend_id
      t.foreign_key :friendship_requests, column: :friendship_request_id

      t.timestamps
    end
  end
end
