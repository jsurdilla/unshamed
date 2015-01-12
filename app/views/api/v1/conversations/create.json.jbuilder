json.conversation do
  json.partial! 'api/v1/conversations/show_preview', conversation: @conversation, target_user: @target_user
end

