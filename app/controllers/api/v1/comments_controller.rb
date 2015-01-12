class Api::V1::CommentsController < ApplicationController

  before_action :authenticate_user!

  def index
    if params[:preview]
      comment_svc = CommentSvc.new(post_ids: params[:post_ids].split(','), journal_entry_ids: params[:journal_entry_ids].split(','))
      @comments = comment_svc.comments
      render partial: 'preview'
    else
      @comments = Comment.for_post_ids(params[:post_ids].split(',')) if params[:post_ids]
    end
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
