class Api::V1::PostsController < ApplicationController

  before_action :authenticate_user!

  def create
    @post = Post.new(post_params)
    @post.author = current_user
    if @post.save
      render action: :show
    else
      render json: { errors: @post.errors }, status: :unprocessable_entity
    end
  end

  private

  def post_params
    params.require(:post).permit(
      :body,
      :feeling
    )
  end

end
