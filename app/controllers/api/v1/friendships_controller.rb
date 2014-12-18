class Api::V1::FriendshipsController < ApplicationController

  before_action :authenticate_user!

  def destroy
    @user = User.find(params[:user_id])
    if friendship_records = Friendship.friendship_records(current_user.id, @user.id)
      Friendship.transaction do
        friendship_records.delete_all
        head :ok
      end
    else
      head :unprocessable_entity
    end
  end

end
