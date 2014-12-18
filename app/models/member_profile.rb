class MemberProfile < ActiveRecord::Base

  belongs_to :user

  delegate :journal_entries, :posts, to: :user

  def update_timeline_groups(from, to)
    return if from.sort == to.sort
    RedisCache::StruggleItems.new(from).change_member_struggles(user.id, to)
  end

  def update_member_group_memberships(from, to)
    return if from.sort == to.sort
    RedisCache::StruggleMembers.new(from).change_member_struggles(user.id, to)
  end

end
