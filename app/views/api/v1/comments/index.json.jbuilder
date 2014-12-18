json.items do
  json.array! @comments.group_by(&:commentable).each do |commentable, comments|
    json.item do
      json.(commentable, :id)
      json.type commentable.class.name
    end

    json.partial! 'api/v1/comments/single', comments: comments, remaining: comments.first.remaining, total: comments.first.total
  end
end
