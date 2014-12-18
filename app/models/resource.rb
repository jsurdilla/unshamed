class Resource < ActiveRecord::Base

  before_save :modify_timeline_groups
  before_destroy :remove_from_timeline_groups

  private

  def modify_timeline_groups
    return unless struggles_changed?

    RedisCache::ResourceTimeline.new(struggles_was).remove_items(self)
    RedisCache::ResourceTimeline.new(struggles).add_items(self)
  end

  def remove_from_timeline_groups
    RedisCache::ResourceTimeline.new(struggles).remove_items(self)
  end
end
