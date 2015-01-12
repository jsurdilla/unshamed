class Api::V1::MeController < ApplicationController

  before_action :authenticate_user!

  def timeline
    user_ids = current_user.friends.map(&:id) + [current_user.id]
    @posts           = Post.where(author_id: user_ids).order('created_at DESC').page(params[:page]).per(20)
    @journal_entries = JournalEntry.where(['updated_at >= ?', @posts.map(&:updated_at).min])

    @items = (@posts + @journal_entries).sort_by(&:updated_at).reverse
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
