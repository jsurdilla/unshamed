class RedisCache::AssociatedZset
  include RedisCache::Utils

  PER_PAGE = 15

  def initialize(subject, association_name)
    @subject, @association_name = subject, association_name
  end

  def add(score_member_pairs)
    score_member_pairs = score_member_pairs.is_a?(Array) ? score_member_pairs : [score_member_pairs]
    redis.zadd(key, score_member_pairs)
  end

  def remove(members)
    members = [members].flatten.compact.uniq.map(&:to_s)
    redis.zrem(key, members)
  end

  def members(page=1, per_page=PER_PAGE)
    redis.zrevrange(key, (page - 1) * per_page, page * per_page - 1)
  end

  private

  def key
    format('%s:%s', @subject, @association_name)
  end
end