json.set! :posts do
  json.partial! 'api/v1/posts/show', collection: @posts, as: :post
end

