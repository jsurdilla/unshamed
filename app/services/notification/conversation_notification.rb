module Notification
  class ConversationNotification

    MESSAGE_COUNT_CHANGED = 'message-count-changed'

    def self.message_count_notification(users, client_socket_id=nil)
      users = [users].flatten
      unread_count = Conversation::ConversationQuery.unread_count(users.map(&:id))

      users.each do |user|
        channel = "private-user#{user.id}"
        count = unread_count.find { |uc| uc['receiver_id'] === user.id.to_s }
        Pusher.trigger(channel, MESSAGE_COUNT_CHANGED, count && count['count'], { socket_id: client_socket_id })
      end
    end
  end
end