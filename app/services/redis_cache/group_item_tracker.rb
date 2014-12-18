module RedisCache
  module GroupItemTracker
    extend ActiveSupport::Concern

    included do
      after_save do |item|
        items = [item]

        user = item.user

        # add to user timeline
        ut = RedisCache::UserTimeline.new(user)
        ht = RedisCache::HomeTimeline.new(user.struggles)
        ut.add_private_items(items)

        if item.respond_to?(:public)
          if item.public?
            ut.add_public_items(items)
            ht.add_items(items)
          else
            ut.remove_public_items(items)
            ht.remove_items(items)
          end
        else # always public
          ut.add_public_items(items)
          ht.add_items(items)
        end
      end

      before_destroy do |item|
        # TODO
      end
    end
  end
end
