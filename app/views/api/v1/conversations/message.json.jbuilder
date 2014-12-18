json.message do
  json.partial! 'api/v1/conversations/message', message: @receipt.message
end
