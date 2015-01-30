json.set! :friendship_requests do
  json.partial! 'api/v1/friendship_requests/show', collection: @friendship_requests, as: :friendship_request
end

