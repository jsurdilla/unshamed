class Friendship < ActiveRecord::Base

  belongs_to :user
  belongs_to :friend, class_name: 'User'

  def self.connect_friends!(friendship_request)
    Friendship.transaction do
      Friendship.create(
        user_id:               friendship_request.user.id,
        friend_id:             friendship_request.receiver.id,
        friendship_request_id: friendship_request.id
      )
      Friendship.create(
        user_id:               friendship_request.receiver.id,
        friend_id:             friendship_request.user.id,
        friendship_request_id: friendship_request.id
      )
    end
  end

  def self.friendship_records(user_id, friend_id)
    Friendship.where(["(user_id = :user_id AND friend_id = :friend_id) OR (user_id = :friend_id AND friend_id = :user_id)", {
      user_id: user_id, friend_id: friend_id
    }])
  end

end
