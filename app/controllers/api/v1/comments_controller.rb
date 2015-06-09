class Api::V1::CommentsController < ApplicationController

  before_action :authenticate_user!

  def index
    if params[:preview]
      comment_svc = CommentSvc.new(post_ids: params[:post_ids].split(','), journal_entry_ids: params[:journal_entry_ids].split(','))
      @comments = comment_svc.comments
    else
      @comments = Comment.for_post_ids(params[:post_ids].split(',')) if params[:post_ids]
    end
  end

  # Fetches the next page of comment for a specific item.
  def next_page
    comment = Comment.find(params[:id])
    limit = params[:limit] || 20

    @remaining = [Comment.for_commentable(comment.commentable).where('created_at < ?', comment.created_at).order('created_at DESC').count - limit, 0].max
    @total     = Comment.for_commentable(comment.commentable).count
    @comments  = Comment.for_commentable(comment.commentable).where('created_at < ?', comment.created_at).order('created_at DESC').limit(limit).reverse.to_a

    render action: :single
  end

  def create
    @comment = Comment.new(comment_params)
    @comment.author = current_user
    if @comment.save
      FeedItemMailer.new_comment(@comment.commentable.user, @comment.commentable).deliver

      payload = JSON.parse(render_template('api/v1/comments/show', { :@comment => @comment }))
      channels = RedisCache::StruggleMembers.new(current_user.struggles).items(1).map { |x| "private-user#{x.split(':').last}" }
      Pusher.trigger(channels, 'new-comment', payload, { socket_id: client_socket_id })
      render action: :show
    else
      render json: { errors: @comment.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    @comment = Comment.find(params[:id])
    if @comment
      # Allow deletion only if the user authored the comment or owns the post commented on.
      if (@comment.user_id === current_user.id || @comment.commentable.user_id === current_user.id) && @comment.destroy
        render status: :ok, json: {}
      else
        render status: :unprocessable_entity, json: { message: "Unable to delete comment" }
      end
    else
      render status: :unprocessable_entity, json: { message: "Comment does not exist" }
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

  def render_template(template, locals)
    render_to_string({
      template: template,
      locals: locals
    })
  end
end
