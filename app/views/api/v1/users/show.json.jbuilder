json.user do
  json.partial! 'api/v1/users/show', user: @user
end
