class RedisCache::AssociatedSet
  include RedisCache::Utils

  def initialize(subject, association_name)
    @subject, @association_name = subject, association_name
  end

  def add(members)
    members = [members].flatten.compact.uniq.map(&:to_s)
    redis.sadd(key, members)
  end

  def remove(members)
    members = [members].flatten.compact.uniq.map(&:to_s)
    redis.srem(key, members)
  end

  def total_count
    redis.scard(key)
  end

  def all
    redis.smembers(key)
  end

  def is_member?(potential_member)
    redis.sismember(key, potential_member) 
  end

  private

  def key
    format('%s:%s', @subject, @association_name)
  end
end