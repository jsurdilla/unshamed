module RedisCache
  class StruggleItems
    include RedisCache::Utils

    delegate :remove_items, :items, to: :@multi_group_zset

    def initialize(struggles)
      @struggles = struggles.is_a?(Array) ? struggles.sort : [struggles].flatten.sort
      @multi_group_zset = MultiGroupKeyZset.new('struggles', 'items', struggles, self)
    end

    def add_journal_entry(journal_entry)
      return unless journal_entry.public?
      @multi_group_zset.add_items([journal_entry])
    end

    def add_post(post)
      @multi_group_zset.add_items([post])
    end

    def change_member_struggles(user_id, new_struggles)
      member_posts = Post.select('posts.id, posts.created_at').joins(user: :member_profile)
        .where('posts.user_id = ?', user_id).order('posts.created_at DESC').first(10_000)
      journal_entries = JournalEntry.select('journal_entries.id, journal_entries.created_at').publics.joins(user: :member_profile)
        .where('journal_entries.user_id = ?', user_id).order('journal_entries.created_at DESC').first(10_000)

      @multi_group_zset.reclassify(member_posts + journal_entries, new_struggles)
    end

    def initial_items(struggle)
      member_posts = Post.select('posts.id, posts.created_at').joins(user: :member_profile)
        .where('? = ANY(struggles)', struggle).order('posts.created_at DESC').first(10_000)
      mhp_posts = Post.select('posts.id, posts.created_at').joins(user: :mhp_profile)
        .where('? = ANY(struggles)', struggle).order('posts.created_at DESC').first(10_000)
      journal_entries = JournalEntry.select('journal_entries.id, journal_entries.created_at').publics.joins(user: :member_profile)
        .where('? = ANY(struggles)', struggle).order('journal_entries.created_at DESC').first(10_000)

      items = member_posts + mhp_posts + journal_entries
    end
  end
end