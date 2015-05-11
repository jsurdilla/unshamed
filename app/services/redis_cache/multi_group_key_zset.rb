class RedisCache::MultiGroupKeyZset
  include RedisCache::Utils

  PER_PAGE = 15

  def initialize(group_name, association, groups, loader)
    raise "group_name, association and groups are required parameters." if [group_name, association, groups].any?(&:blank?)
    @group_name, @association, @groups, @loader = group_name, association, groups.sort, loader
  end

  def initialized_groups
    existences = redis.pipelined do
      @groups.map do |group|
        redis.exists(single_group_key(group))
      end
    end
    existences.zip(@groups).inject([]) { |memo, (exists, group)| exists ? memo << group : memo }
  end

  def uninitialized_groups
    @groups - initialized_groups
  end

  # Adds the items to individual group as well as the aggregate key. If a single group isn't
  # initialized, it will yield to the block that's responsible for returning an array of items
  # to be preloaded.
  def add_items(items)
    items = items.is_a?(Array) ? items : [items]

    load_uninitialized_groups
    load_aggregate

    redis.pipelined do
      @groups.each { |group| redis.zadd(single_group_key(group), to_zset_pairs(items)) }
      redis.zadd(aggregate_key, to_zset_pairs(items))
    end

    # TODO: clean this up
    keys = redis.pipelined do
      @groups.map { |g| redis.scan(0, match: format('%s:*%s*:%s', @group_name, g, @association), count: 500) }
    end.map(&:last).flatten.uniq

    # only get multi-group keys
    multi_group_keys = keys.select { |k| k.match(/#{@group_name}:.*\..*:#{@association}/) }
    multi_group_keys.each do |mgk|
      constituent_keys = mgk.match(/#{@group_name}:(.*\..*):#{@association}/).captures.first.split('.').map { |g| single_group_key(g) }
      redis.zunionstore mgk.gsub("#{redis.namespace}:", ''), constituent_keys, aggregate: :max
    end
  end

  def remove_items(items)
    items = [items].flatten

    # TODO: clean this up
    keys = redis.pipelined do
      @groups.map { |g| redis.scan(0, match: format('%s:*%s*:%s', @group_name, g, @association), count: 500) }
    end.map(&:last).flatten.uniq

    redis.pipelined do
      keys.each do |key|
        redis.zrem(key.gsub("#{redis.namespace}:", ''), to_zset_member_strings(items)) # TODO add test to check the current and related keys are removed from
      end
    end
  end

  def reclassify(items, new_groups)
    new_groups = new_groups.sort
    return if @groups == new_groups

    groups_to_remove_from = @groups - new_groups
    groups_to_add_to = new_groups - @groups

    redis.pipelined do
      groups_to_remove_from.each { |g| redis.zrem(single_group_key(g), to_zset_member_strings(items)) }
      groups_to_add_to.each { |g| redis.zadd(single_group_key(g), to_zset_pairs(items)) }
    end

    # collect all related keys
    # TODO: note that the count option is necessary to avoid paging through early on while our key space is still small.
    # As the data gets bigger, we'll likely need to page through the scan results.
    keys = redis.pipelined do
      (@groups | groups_to_add_to).map { |g| redis.scan(0, match: format('%s:*%s*:%s', @group_name, g, @association), count: 500) }
    end.map(&:last).flatten.uniq

    # only get multi-group keys
    multi_group_keys = keys.select { |k| k.match(/#{@group_name}:.*\..*:#{@association}/) }
    multi_group_keys.each do |mgk|
      constituent_keys = mgk.match(/#{@group_name}:(.*\..*):#{@association}/).captures.first.split('.').map { |g| single_group_key(g) }
      redis.zunionstore mgk.gsub("#{redis.namespace}:", ''), constituent_keys, aggregate: :max
    end
  end

  def items(page, per_page=PER_PAGE)
    page = page.to_i

    load_uninitialized_groups
    load_aggregate
    redis.zrevrange(aggregate_key, (page - 1) * PER_PAGE, page * PER_PAGE - 1)
  end

  def single_group_key(group)
    format('%s:%s:%s', @group_name, group, @association)
  end

  def aggregate_key
    format('%s:%s:%s', @group_name, @groups.join('.'), @association)
  end

  protected

  def load_uninitialized_groups
    uninitialized_groups = uninitialized_groups()
    return if uninitialized_groups.empty?

    redis.pipelined do
      uninitialized_groups.each do |group|
        items = @loader.initial_items(group)
        next if items.empty?
        redis.zadd(single_group_key(group), to_zset_pairs(items))
      end
    end
  end

  def load_aggregate(force=false)
    if @groups.length > 1 && (force || !redis.exists(aggregate_key))
      redis.zunionstore aggregate_key, @groups.map { |s| single_group_key(s) }, aggregate: :max
    end
  end

end