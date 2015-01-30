module RedisCache
  class ResourceTimeline
    include Utils

    PER_PAGE = 15

    def self.items_key(groups)
      "groups:#{[groups].flatten.sort.join('-')}:resources"
    end

    def initialize(groups)
      @groups = groups
    end

    def single?
      groups.count == 1
    end

    def add_items(items)
      items = [items].flatten
      if single?
        refresh unless exists?
      else
        refresh_from_individual_groups unless exists?
        add_to_individual_groups(items)
      end
      redis.zadd(items_key, to_zset_pairs(items))
    end

    def remove_items(items)
      items = [items].flatten

      keys = redis.pipelined do
        groups.map do |group|
          [redis.keys("*-#{group}*"), redis.keys("*#{group}-*"), redis.keys("*:#{group}:*")]
        end
      end.flatten.uniq.map { |key| key.gsub(/^timeline:/, '') }

      redis.pipelined do
        keys.each { |key| redis.zrem(key, to_zset_member_strings(items)) }
      end
    end

    def items(page, per_page=PER_PAGE)
      page = page.to_i

      refresh_from_individual_groups unless exists?
      redis.zrevrange(items_key, (page - 1) * PER_PAGE, page * PER_PAGE - 1)
    end

    def items_key
      self.class.items_key(groups)
    end

    def exists?
      redis.exists(items_key)
    end

    def refresh_from_individual_groups
      refresh_individual_groups
      redis.pipelined do
        redis.zunionstore(items_key, groups.map { |group| ResourceTimeline.items_key(group) })
        redis.zremrangebyrank(items_key, 0, -10001) # only keep the top 10,000
      end
    end

    def groups
      [@groups].flatten
    end

    def refresh
      return unless single?
      resources = Resource.where("? = ANY(struggles)", group).all
      redis.zadd(items_key, to_zset_pairs(resources))
    end


    private

    def group
      groups.first
    end

    def refresh_individual_groups
      groups.each { |group| ResourceTimeline.new(group).refresh }
    end

    def add_to_individual_groups(items)
      groups.each { |group| ResourceTimeline.new(group).add_items(items) }
    end
  end
end
