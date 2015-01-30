module RedisCache
  module GroupItemTracker
    extend ActiveSupport::Concern

    included do
      after_save do |item|
        items = [item]

        if item.respond_to? :author
          user = item.author
        elsif item.respond_to? :user
          user = item.user
        end

        # add to user timeline
        ut = RedisCache::UserTimeline.new(user)
        ut.add_private_items(items)
        ut.add_public_items(items)

        # add to home timeline
        ht = RedisCache::HomeTimeline.new(user.struggles)
        ht.add_items(items)
      end

      before_destroy do |item|
        # TODO
      end
    end
  end
end
