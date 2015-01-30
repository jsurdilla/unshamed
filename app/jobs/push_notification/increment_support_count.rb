module PushNotification
  class IncrementSupportCount
    @queue = :push_notifications

    def self.perform(supportable_type, supportable_id, increment, client_socket_id)
      supportable = supportable_type.constantize.find(supportable_id)

      # fetch all members of this group
      if supportable.respond_to?(:author)
        user = supportable.author
      else
        user = supportable.user
      end
      subscribers = RedisCache::GroupMembers.new(user.struggles).items(1, 10000000).map { |x| x.split(':').last }.uniq

      # array of channels
      channels = subscribers.map { |nid| "private-user#{nid}" }

      payload = {
        increment:        increment,
        supportable_type: supportable_type,
        supportable_id:   supportable_id
      }

      Pusher.trigger(channels, 'support-count-change', payload, { socket_id: client_socket_id })
    end
  end
end
