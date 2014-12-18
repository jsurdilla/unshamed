class MhpProfile < ActiveRecord::Base
  belongs_to :user

  before_save :modify_cached_groups

  private

  def modify_cached_groups
    return unless struggles_changed?
    RedisCache::GroupMhps.new(struggles_was).remove_items(self.user)
    RedisCache::GroupMhps.new(struggles).add_items(self.user)
  end
end
