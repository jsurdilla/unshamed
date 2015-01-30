class Api::V1::ResourcesController < ApplicationController

  before_action :authenticate_user!

  def index
    type_id_pairs = RedisCache::ResourceTimeline.new(current_user.struggles).items(params[:page])
    grouped       = RedisCache::RedisResponseUtils.group_type_id_pairs(type_id_pairs)
    @posts        = Resource.where(id: grouped['resource']) if grouped['resource']
    @resources    = RedisCache::RedisResponseUtils.order_instances_to_type_id_pairs(type_id_pairs, @posts)
    render json: { resources: @resources }
  end
end
