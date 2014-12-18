json.(message, :body)
json.sender do
  json.(message.sender, :first_name, :last_name, :full_name)
  json.profile_pictures do
    json.thumb message.sender.profile_picture(:thumb)
  end
end
