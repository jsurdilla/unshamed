json.items do
  json.array! @comments.group_by(&:commentable).each do |commentable, comments|
    json.(commentable, :id)
    json.total comments.first.total
    json.type commentable.class.name

    json.comments comments, partial: 'api/v1/comments/show', as: :comment
  end
end
