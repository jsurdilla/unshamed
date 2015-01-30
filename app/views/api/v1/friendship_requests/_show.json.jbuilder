json.(friendship_request, :id, :state)

json.user do
  json.partial! 'api/v1/shared/user_default', user: friendship_request.user
end

json.receiver do
  json.partial! 'api/v1/shared/user_default', user: friendship_request.receiver
end
