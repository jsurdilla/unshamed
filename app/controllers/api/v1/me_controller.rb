class Api::V1::MeController < ApplicationController

  before_action :authenticate_user!, except: :resend_confirmation

  def timeline
    type_id_pairs = RedisCache::StruggleItems.new(current_user.struggles).items(params[:page] || 1)
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
    old_struggles = current_user.struggles
    current_user.update(onboarding_params)

    new_struggles = current_user.struggles

    current_user.member_profile.update_timeline_groups(old_struggles, new_struggles)
    current_user.member_profile.update_member_group_memberships(old_struggles, new_struggles)

    @user = current_user
    render file: 'api/v1/users/show'
  end

  def resend_confirmation
    user = User.where(email: params[:email]).first
    if user
      if !user.confirmed?
        user.send_confirmation_instructions
        render json: {}
      else
        render status: :unprocessable_entity, json: { message: 'Email not found.' }
      end
    else
      head :unprocessable_entity
    end
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
      member_profile_attributes: [struggles: []]
    )
  end

end
