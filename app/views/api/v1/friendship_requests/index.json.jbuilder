json.set! :incoming_friendship_requests do
  json.partial! 'api/v1/friendship_requests/show', collection: @incoming_and_pending, as: :friendship_request
end

json.set! :outgoing_friendship_requests do
  json.partial! 'api/v1/friendship_requests/show', collection: @outgoing_and_pending, as: :friendship_request
end