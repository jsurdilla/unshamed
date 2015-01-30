json.set! :type, 'Post'
json.(post, :id, :body, :feeling, :created_at, :updated_at)

json.support_count RedisCache::SupportTracker.new(post).supporter_count

json.author do
  json.(post.author, :first_name, :last_name, :full_name)

  json.profile_pictures do
    json.square50 post.author.profile_picture(:square50)
  end
end

