json.set! :type, 'Post'
json.(post, :id, :body, :feeling, :created_at, :updated_at)

json.support_count Support.for(post).count

json.author do
  json.(post.author, :first_name, :last_name, :full_name)

  json.profile_pictures do
    json.thumb post.author.profile_picture(:thumb)
  end
end

