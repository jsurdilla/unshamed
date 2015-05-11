json.set! :type, 'Post'
json.(post, :id, :body, :feeling, :created_at, :updated_at)

json.support_count RedisCache::AssociatedSet.new("#{post.class.name.underscore}:#{post.id}", 'supporters').total_count

json.author do
  json.(post.user, :id, :username, :first_name, :last_name, :full_name)

  json.profile_pictures do
    json.square50 post.user.profile_picture(:square50)
  end
end