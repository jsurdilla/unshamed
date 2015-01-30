json.conversation do
  json.partial! 'api/v1/conversations/show', conversation: @conversation, messages: @messages
end
