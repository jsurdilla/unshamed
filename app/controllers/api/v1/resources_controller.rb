class Api::V1::ResourcesController < ApplicationController

  before_action :authenticate_user!

  def index
    type_id_pairs = RedisCache::StruggleResources.new(current_user.struggles).items(params[:page])
    grouped       = RedisCache::RedisResponseUtils.group_type_id_pairs(type_id_pairs)
    @resources    = Resource.where(id: grouped['resource']) if grouped['resource']
    @resources    = RedisCache::RedisResponseUtils.order_instances_to_type_id_pairs(type_id_pairs, @resources)
    render json: { resources: @resources }
  end
end
