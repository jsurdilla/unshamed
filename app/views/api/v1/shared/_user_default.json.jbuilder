json.(user, :id, :first_name, :last_name, :full_name)
json.profile_pictures do
  json.thumb user.profile_picture(:thumb)
end
