json.(conversation, :id, :subject)

json.participants do
  json.array! conversation.participants, partial: 'api/v1/shared/user_default', as: :user
end

json.messages do
  json.partial! 'api/v1/conversations/message', collection: conversation.messages.order('created_at ASC'), as: :message
end

