class Api::V1::ResourcesController < ApplicationController

  before_action :authenticate_user!

  def index
    type_id_pairs = RedisCache::ResourceTimeline.new(current_user.struggles).items(params[:page])
    grouped = type_id_pairs.inject({}) do |memo, pair|
      item_type, item_id = pair.split(':')
      (memo[item_type] ||= []) << item_id
      memo
    end

    @posts = Resource.where(id: grouped['resource']) if grouped['resource']

    @resources = [@posts].flatten.compact.inject({}) do |memo, item|
      memo["#{item.class.name.underscore}:#{item.id}"] = item
      memo
    end

    @resources = type_id_pairs.map { |pair| @resources[pair] }.compact
    render json: { resources: @resources }
  end
end
