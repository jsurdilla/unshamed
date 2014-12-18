json.(comment, :id, :commentable_type, :commentable_id, :comment, :created_at, :updated_at)

json.author do
  json.(comment.author, :id, :first_name, :last_name, :full_name)
  json.profile_pictures do
    json.square50 comment.author.profile_picture(:square50)
  end
end
