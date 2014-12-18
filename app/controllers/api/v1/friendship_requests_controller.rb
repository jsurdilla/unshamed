class Api::V1::FriendshipRequestsController < ApplicationController

  before_action :authenticate_user!

  def create
    @user = User.find(params[:user_id])
    if request = FriendshipRequest.reverse_request(current_user.id, @user.id)
      request.accept! if request.pending?
      head :ok
    else
      if FriendshipRequest.pending.where(user_id: current_user.id, receiver_id: @user.id).first_or_create
        head :ok
      else
        head :unprocessable_entity
      end
    end
  end

  def destroy
    @user = User.find(params[:user_id])
    if request = FriendshipRequest.identical_request(current_user.id, @user.id)
      if request.destroy
        head :ok
      else
        head :unprocessable_entity
      end
    else
      head :unprocessable_entity
    end
  end

end
