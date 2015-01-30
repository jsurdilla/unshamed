module RedisCache
  class UserTimeline
    include Utils

    PER_PAGE = 25

    def initialize(user)
      @user = user
    end

    def public_items(page, per_page=PER_PAGE)
      page = page.to_i < 1 ? 1 : page.to_i
      per_page = per_page.to_i

      refresh_public_timeline unless public_timeline_exists?
      redis.zrevrange(public_timeline_key, (page - 1) * per_page, page * per_page - 1)
    end

    def private_items(page, per_page=PER_PAGE)
      page = page.to_i < 1 ? 1 : page.to_i
      per_page = per_page.to_i

      refresh_private_timeline unless private_timeline_exists?
      redis.zrevrange(private_timeline_key, (page - 1) * per_page, page * per_page - 1)
    end

    def add_private_items(items)
      redis.zadd(private_timeline_key, to_zset_pairs(items))
    end

    def add_public_items(items)
      return if items.empty?
      redis.zadd(public_timeline_key, to_zset_pairs(items))
    end

    def private_timeline_exists?
      redis.exists(private_timeline_key)
    end

    def public_timeline_exists?
      redis.exists(public_timeline_key)
    end

    def private_timeline_key
      "users:#{@user.id}:private_timeline"
    end

    def public_timeline_key
      "users:#{@user.id}:public_timeline"
    end

    def refresh_private_timeline
      return if redis.exists(private_timeline_key)
      add_private_items(@user.posts + @user.journal_entries)
    end

    def refresh_public_timeline
      return if redis.exists(public_timeline_key)
      add_public_items(@user.posts + @user.journal_entries.publics)
    end
  end
end
