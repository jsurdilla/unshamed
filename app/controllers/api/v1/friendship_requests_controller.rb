class Api::V1::FriendshipRequestsController < ApplicationController

  before_action :authenticate_user!
  before_action :find_other_user

  def index
    @friendship_requests = current_user.incoming_friendship_requests.pending
  end

  def create
    if request = current_user.pending_friend_requests_from(@user).first
      accept
    else
      if request = @user.pending_friend_requests_from(current_user).first_or_create
        payload = JSON.parse(render_template('api/v1/friendship_requests/show', { :@friendship_request => request }))
        payload[:count] = @user.incoming_friendship_requests.pending.count
        Pusher.trigger("private-user#{@user.id}", 'new-friend-request', payload, { socket_id: client_socket_id })
        head :ok
      else
        head :unprocessable_entity
      end
    end
  end

  def accept
    if request = current_user.pending_friend_requests_from(@user).first
      request.accept!
      payload = { count: @user.incoming_friendship_requests.pending.count, friendship_request: request }
      Pusher.trigger("private-user#{@user.id}", 'accepted-friend-req', payload, { socket_id: client_socket_id })
      head :ok
    else
      head :unprocessable_entity
    end
  end

  def reject
    if request = current_user.pending_friend_requests_from(@user).first
      request.reject!
      payload = { count: @user.incoming_friendship_requests.pending.count, friendship_request: request }
      Pusher.trigger("private-user#{@user.id}", 'rejected-friend-req', payload, { socket_id: client_socket_id })
      head :ok
    else
      head :unprocessable_entity
    end
  end

  def destroy
    if request = @user.pending_friend_requests_from(current_user).first
      if request.destroy
        payload = { count: @user.incoming_friendship_requests.pending.count, friendship_request: request }
        Pusher.trigger("private-user#{@user.id}", 'cancel-friend-request', payload, { socket_id: client_socket_id })
        head :ok
      else
        head :unprocessable_entity
      end
    else
      head :unprocessable_entity
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
