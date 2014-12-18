class Api::V1::FriendshipRequestsController < ApplicationController

  before_action :authenticate_user!
  before_action :find_other_user, only: :create

  def index
    @incoming_and_pending = current_user.incoming_friendship_requests.pending
    @outgoing_and_pending = current_user.outgoing_friendship_requests.pending
  end

  def create
    if request = current_user.pending_friend_requests_from(@user).first
      accept
    else
      if @friendship_request = @user.pending_friend_requests_from(current_user).first_or_create
        payload = JSON.parse(render_template('api/v1/friendship_requests/show', { :@friendship_request => @friendship_request }))
        payload[:count] = @user.incoming_friendship_requests.pending.count
        Pusher.trigger("private-user#{@user.id}", 'new-friend-request', payload, { socket_id: client_socket_id })
        render action: :show
      else
        render status: :unprocessable_entity, json: {}
      end
    end
  end

  def accept
    if @friendship_request = current_user.incoming_friendship_requests.pending.find(params[:id])
      @user = @friendship_request.user
      @friendship_request.accept!
      payload = JSON.parse(render_template('api/v1/friendship_requests/show', { :@friendship_request => @friendship_request }))
      Pusher.trigger("private-user#{@user.id}", 'accepted-friend-req', payload, { socket_id: client_socket_id })
      render action: :show
    else
      render status: :unprocessable_entity, json: {}
    end
  end

  def reject
    if @friendship_request = current_user.incoming_friendship_requests.pending.find(params[:id])
      @user = @friendship_request.user
      @friendship_request.reject!
      payload = { count: @user.incoming_friendship_requests.pending.count, friendship_request: @friendship_request }
      Pusher.trigger("private-user#{@user.id}", 'rejected-friend-req', payload, { socket_id: client_socket_id })
      render status: :ok, json: {}
    else
      render status: :unprocessable_entity, json: {}
    end
  end

  def destroy
    if @friendship_request = current_user.outgoing_friendship_requests.pending.find(params[:id])
      @user = @friendship_request.receiver
      if @friendship_request.destroy
        payload = { count: @user.incoming_friendship_requests.pending.count, friendship_request: @friendship_request }
        Pusher.trigger("private-user#{@user.id}", 'cancel-friend-request', payload, { socket_id: client_socket_id })
        render status: :ok, json: {}
      else
        render status: :unprocessable_entity, json: {}
      end
    else
      render status: :unprocessable_entity, json: {}
    end
  end

  private

  def find_other_user
    @user = User.find(params[:user_id])
  end

  def render_template(template, locals)
    render_to_string({
      template: template,
      locals: locals
    })
  end
end
