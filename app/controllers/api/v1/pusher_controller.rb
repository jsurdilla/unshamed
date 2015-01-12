class Api::V1::PusherController < ApplicationController

  before_action :authenticate_user!

  def auth
    if current_user
      response = Pusher[params[:channel_name]].authenticate(params[:socket_id], {
        :user_id => current_user.id,
        :user_info => {
          :name => current_user.name,
          :email => current_user.email
        }
      })
      render :json => response
    else
      render text: 'Forbidden', status: :forbidden
    end
  end

end

