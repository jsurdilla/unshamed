module RedisCache
  class HomeTimeline
    include Utils

    PER_PAGE = 30

    def self.items_key(groups)
      "groups:#{[groups].flatten.sort.join('-')}:home_timeline"
    end

    def self.relevant_items_keys(groups)
      redis = RedisCache.redis
      redis.pipelined do
        groups.map do |group|
          [redis.keys("*-#{group}*"), redis.keys("*#{group}-*"), redis.keys("*:#{group}:*")]
        end
      end.flatten.uniq.map { |key| key.gsub(/^timeline:/, '') }
    end

    def initialize(groups)
      @groups = groups
    end

    def single?
      return groups.count == 1
    end

    def add_items(items)
      items = [items].flatten

      # If the key doesn't exist yet, refresh from database
      if single?
        refresh unless exists?
      else
        refresh_from_individual_groups unless exists?
        add_to_individual_groups(items)
      end
      relevant_items_keys.each { |items_key| redis.zadd(items_key, to_zset_pairs(items)) }
      redis.zadd(items_key, to_zset_pairs(items))
    end

    def remove_items(items)
      items = [items].flatten
      relevant_items_keys.each { |items_key| redis.zrem(items_key, to_zset_member_strings(items)) }
    end

    def items_key
      self.class.items_key(groups)
    end

    def relevant_items_keys
      self.class.relevant_items_keys(groups)
    end

    def items(page, per_page=PER_PAGE)
      page = page.to_i

      refresh_from_individual_groups unless exists?
      redis.zrevrange(items_key, (page - 1) * PER_PAGE, page * PER_PAGE - 1)
    end


    def exists?
      redis.exists(items_key)
    end

    def groups
      [@groups].flatten
    end

    def refresh
      return unless single?
      posts = Post.joins(:author).where('? = ANY(struggles)', group).order('created_at DESC').first(10_000)
      journal_entries = JournalEntry.publics.joins(:user).where('? = ANY(struggles)', group).order('created_at DESC').first(10_000)
      items = posts + journal_entries
      redis.zadd(items_key, to_zset_pairs(items)) unless items.empty?
      redis.zremrangebyrank(items_key, 0, -10001) # only keep the top 10,000
    end

    def refresh_from_individual_groups
      refresh_individual_groups
      redis.pipelined do
        redis.zunionstore(items_key, groups.map { |group| HomeTimeline.items_key(group) })
        redis.zremrangebyrank(items_key, 0, -10001) # only keep the top 10,000
      end
    end


    private

    def group
      groups.first
    end

    def refresh_individual_groups
      groups.each { |group| HomeTimeline.new(group).refresh }
    end

    def add_to_individual_groups(items)
      groups.each { |group| HomeTimeline.new(group).add_items(items) }
    end

  end
end
