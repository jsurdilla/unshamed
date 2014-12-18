class Api::V1::ConversationsController < ApplicationController

  before_action :authenticate_user!
  before_action :find_conversation, only: [:show, :reply]

  def show
    @conversation.mark_as_read(current_user)
    render
  end

  def inbox
    @conversations = current_user.mailbox.inbox.page(params[:page]).per(20)
    @preview = true
    render :index
  end

  def sentbox
    @conversations = current_user.mailbox.sentbox.page(params[:page]).per(20)
    @preview = true
    render :index
  end

  def reply
    @receipt = current_user.reply_to_conversation(@conversation, params[:body])
    render action: 'message'
  end

  private

  def find_conversation
    @conversation = current_user.mailbox.conversations.where(id: params[:id]).first
  end

end
