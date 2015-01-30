class Api::V1::TimelinesController < ApplicationController

  before_action :authenticate_user!

  def show
    user = User.where(id: params[:user_id]).first
    if current_user === user
      type_id_pairs = RedisCache::UserTimeline.new(user).private_items(params[:page])
    else
      type_id_pairs = RedisCache::UserTimeline.new(user).public_items(params[:page])
    end
    Rails.logger.ap type_id_pairs
    grouped = type_id_pairs.inject({}) do |memo, pair|
      item_type, item_id = pair.split(':')
      (memo[item_type] ||= []) << item_id
      memo
    end

    @posts           = Post.where(id: grouped['post']) if grouped['post']
    @journal_entries = JournalEntry.where(id: grouped['journal_entry']) if grouped['journal_entry']

    Rails.logger.ap grouped
    Rails.logger.ap @journal_entries

    @items = [@posts, @journal_entries].flatten.compact.inject({}) do |memo, item|
      memo["#{item.class.name.underscore}:#{item.id}"] = item
      memo
    end

    @items = type_id_pairs.map { |pair| @items[pair] }
  end

end
