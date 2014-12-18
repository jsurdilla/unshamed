module PushNotification
  class IncrementSupportCount
    @queue = :push_notifications

    def self.perform(supportable_type, supportable_id, increment, client_socket_id)
      supportable = supportable_type.constantize.find(supportable_id)

      user = supportable.user
      channels = RedisCache::StruggleMembers.new(user.struggles).items(1).map { |x| "private-user#{x.split(':').last}" }

      payload = {
        increment:        increment,
        supportable_type: supportable_type,
        supportable_id:   supportable_id
      }

      Pusher.trigger(channels, 'support-count-change', payload, { socket_id: client_socket_id })
    end
  end
end