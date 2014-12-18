json.(message, :id, :body, :created_at)
json.sender do
  json.(message.sender, :id, :first_name, :last_name, :full_name)
  json.profile_pictures do
    json.square50 message.sender.profile_picture(:square50)
  end
end
