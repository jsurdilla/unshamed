module RedisCache
  module GroupItemTracker
    extend ActiveSupport::Concern

    included do
      before_save do |item|
        RedisCache::HomeTimeline.new(item.item_groups).add_items(item)
      end

      before_destroy do |item|
        RedisCache::HomeTimeline.new(item.item_groups).remove_items(item)
      end
    end
  end
end
