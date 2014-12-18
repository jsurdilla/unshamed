class Api::V1::TimelinesController < ApplicationController

  before_action :authenticate_user!

  def show
    user = User.where(id: params[:user_id]).first
    if current_user === user
      type_id_pairs = RedisCache::MemberPrivateTimeline.new(user).items(params[:page])
    else
      type_id_pairs = RedisCache::MemberPublicTimeline.new(user).items(params[:page])
    end

    grouped = RedisCache::RedisResponseUtils.group_type_id_pairs(type_id_pairs)
    @posts           = Post.where(id: grouped['post'])                  if grouped['post']
    @journal_entries = JournalEntry.where(id: grouped['journal_entry']) if grouped['journal_entry']

    @items = RedisCache::RedisResponseUtils.order_instances_to_type_id_pairs(type_id_pairs, @posts, @journal_entries)
  end

end
