json.(conversation, :id)

json.set! :most_recent_message, conversation.messages.last.body
json.read target_user ? conversation.is_read?(target_user) : false

json.participants do
  json.array! conversation.participants, partial: 'api/v1/shared/user_default', as: :user
end


