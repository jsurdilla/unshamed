class Api::V1::SupportsController < ApplicationController
  include RedisCache::Utils

  before_action :authenticate_user!
  before_action :find_support, only: [:toggle, :create, :destroy]

  def item_summaries
    post_ids = (params[:post_ids] || '').split(',')
    journal_entry_ids = (params[:journal_entry_ids] || '').split(',')

    summaries = {}
    summaries['Post'] = post_ids.inject({}) do |memo, post_id|
      as = RedisCache::AssociatedSet.new("post:#{post_id}", 'supporters')
      res = { count: as.total_count, is_supporter: as.is_member?(current_user.id) }
      res[:count] > 0 ? memo.merge(post_id => res) : memo
    end

    summaries['JournalEntry'] = journal_entry_ids.inject({}) do |memo, journal_entry_id|
      as = RedisCache::AssociatedSet.new("journal_entry:#{journal_entry_id}", 'supporters')
      res = { count: as.total_count, is_supporter: as.is_member?(current_user.id) }
      res[:count] > 0 ? memo.merge(journal_entry_id => res) : memo
    end

    render json: { support_summaries: summaries }
  end

  def toggle
    if @support.persisted?
      destroy()
    else
      create()
    end
  end

  def create
    if @support.persisted?
      render json: { result: 'existing' }, status: :ok
    else
      if @support.save
        RedisCache::AssociatedSet.new(to_zset_member_string(@support.supportable), 'supporters').add(current_user.id)
        Resque.enqueue(PushNotification::IncrementSupportCount, @support.supportable_type, @support.supportable_id, 1, client_socket_id)
        render json: { result: 'created' }, status: :created
      else
        head :unprocessable_entity
      end
    end
  end

  def destroy
    if @support.persisted?
      if @support.destroy
        RedisCache::AssociatedSet.new(to_zset_member_string(@support.supportable), 'supporters').remove(current_user.id)
        Resque.enqueue(PushNotification::IncrementSupportCount, @support.supportable_type, @support.supportable_id, -1, client_socket_id)
        render json: { result: 'deleted' }, status: :ok
      else
        head :unprocessable_entity
      end
    else
      head :not_found
    end
  end

  private

  def support_params
    params[:user_id] = current_user.id
    params.require(:support).permit(
      :supportable_type,
      :supportable_id,
      :user_id
    )
  end

  def find_support
    @support = Support.where(support_params).where(user_id: current_user.id).first_or_initialize
  end

end
