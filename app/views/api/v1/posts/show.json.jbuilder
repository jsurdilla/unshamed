json.post do
  json.partial! 'api/v1/posts/show', post: @post
end
