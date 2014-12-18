json.set! :comments do
  json.partial! 'api/v1/comments/show', collection: @comments, as: :comment
end
