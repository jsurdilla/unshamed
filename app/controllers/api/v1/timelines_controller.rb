class Api::V1::TimelinesController < ApplicationController

  before_action :authenticate_user!

  def show
    timeline = Timeline::SingleUserTimeline.new(current_user, User.find(params[:user_id]))
    @items = timeline.compose(params[:page])
  end

end
