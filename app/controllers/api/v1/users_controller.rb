class Api::V1::UsersController < ApplicationController

  before_action :authenticate_user!, except: [:check_username]

  def most_recent
    type_id_pairs = RedisCache::GroupMembers.new(current_user.struggles).items(params[:page])
    grouped       = RedisCache::RedisResponseUtils.group_type_id_pairs(type_id_pairs)
    @users        = User.where(id: grouped['user']).order('created_at DESC') if grouped['user']
    render action: :index
  end

  def show
    @user = User.find(params[:id])
  end

  def check_username
    username = params[:username]
    if username.blank?
      render json: { errors: ['Provider a username'] }, status: :unprocessable_entity
    else
      render json: { exists: User.where(username: username).exists? }
    end
  end

  private

  def onboarding_params
    params.require(:user).permit(
      :username,
      :first_name,
      :last_name,
      :about_me,
      :gender,
      :birthdate
    )
  end

end
