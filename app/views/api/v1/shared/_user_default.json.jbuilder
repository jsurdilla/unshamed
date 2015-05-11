json.(user, :id, :username, :first_name, :last_name, :full_name)
json.profile_pictures do
  json.square50 user.profile_picture(:square50)
end
