json.(conversation, :id, :subject)
json.unread conversation.receipts_for(current_user).where(is_read: false).exists?

json.participants do
  json.array! conversation.participants, partial: 'api/v1/shared/user_default', as: :user
end


