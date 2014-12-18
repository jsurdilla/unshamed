json.(comment, :commentable_type, :commentable_id, :comment, :created_at, :updated_at)

json.author do
  json.(comment.author, :first_name, :last_name, :full_name)
  json.profile_pictures do
    json.thumb comment.author.profile_picture(:thumb)
  end
end
