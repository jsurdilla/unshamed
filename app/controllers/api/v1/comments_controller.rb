class Api::V1::CommentsController < ApplicationController

  before_action :authenticate_user!

  def index
    @comments = Comment.for_post_ids(params[:post_ids].split(',')) if params[:post_ids]
  end

  def create
    @comment = Comment.new(comment_params)
    @comment.author = current_user
    if @comment.save
      render action: :show
    else
      render json: { errors: @comment.errors }, status: :unprocessable_entity
    end
  end

  private

  def comment_params
    params.require(:comment).permit(
      :commentable_type,
      :commentable_id,
      :title,
      :comment
    )
  end

end
