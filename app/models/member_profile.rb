class MemberProfile < ActiveRecord::Base

  belongs_to :user

  before_save :check_timeline_groups
  before_save :modify_cached_groups

  delegate :journal_entries, :posts, to: :user

  private

  def check_timeline_groups
    return unless struggles_changed?
    RedisCache::HomeTimeline.new(struggles_was).remove_items(posts + journal_entries)
    RedisCache::HomeTimeline.new(struggles).add_items(posts + journal_entries)
  end

  def modify_cached_groups
    return unless struggles_changed?
    RedisCache::GroupMembers.new(struggles_was).remove_items(self)
    RedisCache::GroupMembers.new(struggles).add_items(self)
  end

end
