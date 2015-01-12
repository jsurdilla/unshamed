json.(user, :id, :first_name, :last_name, :full_name, :struggles)

json.is_friend current_user.friends.include?(user)
json.has_pending_friend_request !FriendshipRequest.identical_request(current_user.id, user.id).nil?

json.friends user.friends.limit(10), partial: 'api/v1/shared/user_default', as: :user

json.profile_pictures do
  json.square50 user.profile_picture(:square50)
  json.medium user.profile_picture(:medium)
end
