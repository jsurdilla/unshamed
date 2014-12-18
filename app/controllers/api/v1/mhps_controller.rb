class Api::V1::MhpsController < ApplicationController

  before_action :authenticate_user!

  def most_recent
    type_id_pairs = RedisCache::StruggleMhps.new(current_user.struggles).items(params[:page])
    grouped       = RedisCache::RedisResponseUtils.group_type_id_pairs(type_id_pairs)
    @users        = User.where(id: grouped['user']).order('created_at DESC') if grouped['user']
    render 'api/v1/users/index'
  end

end

