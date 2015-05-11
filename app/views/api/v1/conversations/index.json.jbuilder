json.unread_message_count current_user.unread_inbox_count

json.set! :conversations do
  if @preview === true
    json.partial! 'api/v1/conversations/show_preview', collection: @conversations, as: :conversation, target_user: current_user
  else
    json.partial! 'api/v1/conversations/show', collection: @conversations, as: :conversation
  end
end
