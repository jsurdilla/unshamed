require 'pusher'

class Api::V1::ConversationsController < ApplicationController

  before_action :authenticate_user!
  before_action :find_conversation, only: [:show, :reply]

  def index
    @preview = true
    @conversations = current_user.mailbox.conversations.includes(:receipts, :messages)
  end

  def show
    @conversation.mark_as_read(current_user)
    if params[:message_id]
      current_message_created_at = @conversation.messages.find(params[:message_id]).created_at
      @messages = @conversation.messages.where('created_at < ?', current_message_created_at).order('created_at DESC').limit(20).reverse
    else
      @messages = @conversation.messages.order('created_at DESC').limit(20).reverse
    end
  end

  def create
    users = User.where(id: params[:conversation][:user_ids])
    receipt = current_user.send_message(users, params[:body], 'Untitled')
    @conversation = receipt.conversation
    new_conversation_notification(users, @conversation)
  end

  def reply
    @receipt = current_user.reply_to_conversation(@conversation, params[:body])
    @message = @receipt.message
    reply_notification(@receipt.conversation.participants, @message)
    render action: 'message'
  end

  def recipient_autocomplete
    user_ids = RedisCache::FriendshipAutocomplete.find(current_user, params[:query]).map { |f| f.split(':').last }.uniq
    @users = User.onboarded.where(id: user_ids)
  end

  private

  def find_conversation
    @conversation = current_user.mailbox.conversations.where(id: params[:id]).first
  end

  def new_conversation_notification(users, conversation)
    channels = users.map { |user| "private-user#{user.id}" }
    payload = render_template('api/v1/conversations/create.json.jbuilder', { conversation: conversation })
    Pusher.trigger(channels, 'new-message', payload, { socket_id: client_socket_id })
  end

  def reply_notification(users, message)
    channels = users.map { |user| "private-user#{user.id}" }
    payload = render_template('api/v1/conversations/message.json.jbuilder', { message: message })
    Pusher.trigger(channels, 'new-reply', payload, { socket_id: client_socket_id })
  end

  def render_template(template, locals)
    render_to_string({
      template: template,
      locals: locals
    })
  end

end
