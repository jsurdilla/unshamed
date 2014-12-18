class Api::V1::UsersController < ApplicationController

  before_action :authenticate_user!, except: [:check_username]

  def most_recent
    @users = User.onboarded.order('created_at DESC').first(10)
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
