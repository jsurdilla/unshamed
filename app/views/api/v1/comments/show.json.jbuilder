json.comment do
  json.partial! 'api/v1/comments/show', comment: @comment
end
