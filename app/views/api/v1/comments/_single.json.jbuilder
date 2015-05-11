# array of comments
json.comments do
  json.array! comments do |comment|
    # direct comment attributes
    json.(comment, :id, :commentable_type, :commentable_id, :comment, :created_at, :updated_at)

    # comment author
    json.author do
      json.(comment.author, :id, :username, :first_name, :last_name, :full_name)
      json.profile_pictures do
        json.square50 comment.author.profile_picture(:square50)
      end
    end
  end
end

# comment statistics for this item
json._metadata do
  json.remaining remaining
  json.total total
end
