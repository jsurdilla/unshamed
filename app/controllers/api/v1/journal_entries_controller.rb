class Api::V1::JournalEntriesController < ApplicationController

  before_action :authenticate_user!

  def index
    @journal_entries = current_user.journal_entries.order('updated_at DESC')
  end

  def show
    @journal_entry = current_user.journal_entries.find(params[:id])
  end

  def update
    @journal_entry = current_user.journal_entries.find(params[:id])
    if @journal_entry.update(journal_params)
      if @journal_entry.public?
        RedisCache::MemberPublicTimeline.new(current_user).add_items([@journal_entry])
        RedisCache::StruggleItems.new(current_user.struggles).add_journal_entry(@journal_entry)
      else
        RedisCache::MemberPublicTimeline.new(current_user).remove_items([@journal_entry])
        RedisCache::StruggleItems.new(current_user.struggles).remove_items([@journal_entry])
      end
      render action: :show
    else
      render json: { errors: @journal_entry.errors }, status: :unprocessable_entity
    end
  end

  def create
    @journal_entry = JournalEntry.new(journal_params)
    @journal_entry.user = current_user

    if params[:journal_entry][:published] === true
      @journal_entry.published_at = Time.now
    end

    if @journal_entry.save
      if @journal_entry.public?
        RedisCache::MemberPublicTimeline.new(current_user).add_items([@journal_entry])
      end
      RedisCache::MemberPrivateTimeline.new(current_user).add_items([@journal_entry])
      RedisCache::StruggleItems.new(current_user.struggles).add_journal_entry(@journal_entry)
      render action: :show, status: :created
    else
      render json: { errors: @journal_entry.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    @journal_entry = current_user.journal_entries.find(params[:id])
    if @journal_entry.destroy
      render status: :ok, json: {}
    else
      render status: :unprocessable_entity, json: {}
    end
  end

  private

  def journal_params
    params.require(:journal_entry).permit(
      :title,
      :body,
      :posted_at,
      :public
    )
  end

end
