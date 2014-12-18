json.set! :conversations do
  if @preview === true
    json.partial! 'api/v1/conversations/show_preview', collection: @conversations, as: :conversation
  else
    json.partial! 'api/v1/conversations/show', collection: @conversations, as: :conversation
  end
end
