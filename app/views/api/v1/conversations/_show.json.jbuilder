json.(conversation, :id, :subject)

json.messages do
  json.partial! 'api/v1/conversations/message', collection: conversation.messages.order('created_at ASC'), as: :message
end

