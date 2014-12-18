module RedisCache
  class MemberPrivateTimeline
    include RedisCache::Utils

    delegate :add_items, :remove_items, :items, to: :@multi_group_zset

    def initialize(user)
      @user = user
      @groups = ["user_#{@user.id}"]
      @multi_group_zset = MultiGroupKeyZset.new('private_timelines', 'items', @groups, self)
    end

    def initial_items(user)
      member_posts = @user.posts.select('posts.id, posts.created_at')
        .order('posts.created_at DESC').first(10_000)
      journal_entries = @user.journal_entries.select('journal_entries.id, journal_entries.created_at')
        .order('journal_entries.created_at DESC').first(10_000)
      member_posts + journal_entries
    end
  end
end