class Api::V1::FriendsController < ApplicationController

  before_action :authenticate_user!

  def index
    @users = current_user.friends.order('created_at DESC');
    render action: '../users/index'
  end

end
