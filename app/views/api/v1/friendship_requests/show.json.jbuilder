json.friendship_request do
  json.partial! 'api/v1/friendship_requests/show', friendship_request: @friendship_request
end

