class Api::V1::PostsController < ApplicationController

  before_action :authenticate_user!

  def create
    @post = Post.new(post_params)
    @post.user = current_user
    if @post.save
      RedisCache::MemberPublicTimeline.new(current_user).add_items([@post])
      RedisCache::MemberPrivateTimeline.new(current_user).add_items([@post])
      RedisCache::StruggleItems.new(current_user.struggles).add_post(@post)

      payload = JSON.parse(render_template('api/v1/posts/show', { :@post => @post }))
      channels = RedisCache::StruggleMembers.new(current_user.struggles).items(1).map { |x| "private-user#{x.split(':').last}" }
      Pusher.trigger(channels, 'new-post', payload, { socket_id: client_socket_id })

      render action: :show
    else
      render json: { errors: @post.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    @post = current_user.posts.where(id: params[:id]).first
    if @post
      RedisCache::MemberPublicTimeline.new(current_user).remove_items([@post])
      RedisCache::MemberPrivateTimeline.new(current_user).remove_items([@post])
      RedisCache::StruggleItems.new(current_user.struggles).remove_items(@post)

      if @post.destroy
        render status: :ok, json: {}
      else
        render status: :unprocessable_entity, json: { message: 'Unable to delete post.' }
      end
    else
      render status: :unprocessable_entity, json: { message: 'Cannot find post.' }
    end
  end

  private

  def post_params
    params.require(:post).permit(
      :body,
      :feeling
    )
  end

  def render_template(template, locals)
    render_to_string({
      template: template,
      locals: locals
    })
  end

end
