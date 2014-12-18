json.set! :users do
  json.partial! 'api/v1/users/show', collection: @users, as: :user
end
