class Api::V1::MeController < ApplicationController

  before_action :authenticate_user!

  def timeline
    type_id_pairs = RedisCache::HomeTimeline.new(current_user.struggles).items(params[:page])
    grouped = RedisCache::RedisResponseUtils.group_type_id_pairs(type_id_pairs)

    @posts           = Post.where(id: grouped['post']) if grouped['post']
    @journal_entries = JournalEntry.where(id: grouped['journal_entry']) if grouped['journal_entry']

    @items = [@posts, @journal_entries].flatten.compact.inject({}) do |memo, item|
      memo["#{item.class.name.underscore}:#{item.id}"] = item
      memo
    end

    @items = type_id_pairs.map { |pair| @items[pair] }
    render template: '/api/v1/timelines/show'
  end

  def onboard
    current_user.onboarded = true
    current_user.profile_picture = params[:file]
    current_user.update(onboarding_params)

    render json: { user: current_user }
  end

  private

  def onboarding_params
    user_params = params[:user]
    if user_params.is_a?(String)
      user_params = ActionController::Parameters.new(JSON.parse(user_params))
    end

    user_params.permit(
      :username,
      :first_name,
      :last_name,
      :about_me,
      :gender,
      :zip_code,
      :birthdate,
      struggles: []
    )
  end

end
