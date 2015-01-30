module RedisCache
  # SupportTracker manages support information for supportable objects.
  class SupportTracker
    include Utils

    attr_reader :supportable

    # The base key from which all supports-related redis keys are based from.
    # Its format is `posts:1:supports`.
    def self.base_key(supportable)
      "#{supportable.class.name.underscore}:#{supportable.id}"
    end

    # Key for all the supporters on the object. Its format is
    # `supporters:posts:1:supporters`
    def self.supporters_key(supportable)
      "#{base_key(supportable)}:supporters"
    end

    # Initialize every tracker with a supportable object. A supportable object
    # must respond to `supporter_ids`.
    def initialize(supportable)
      @supportable = supportable
    end

    # Add given user_id as a supporter. If it's the first user, it initializes
    # the object by adding all existing supporters.
    def add_supporter(user_id)
      key = SupportTracker.supporters_key(supportable)
      supporter_ids = supportable.supporter_ids.uniq
      return if supporter_ids.empty?
      unless supports_redis.exists(key)
        supports_redis.sadd(key, supporter_ids)
      end
      supports_redis.sadd(key, user_id)
    end

    def remove_supporter(user_id)
      key = SupportTracker.supporters_key(supportable)
      unless supports_redis.exists(key)
        supports_redis.sadd(key, supportable.supporter_ids.uniq)
      end
      supports_redis.srem(key, user_id)
    end

    # Returns all supporter IDs. If they key doesn't exist, it initializes the
    # object by adding all existing supporters.
    def supporter_ids
      key = SupportTracker.supporters_key(supportable)
      unless supports_redis.exists(key)
        supports_redis.sadd(key, supportable.supporter_ids.uniq)
        return supportable.supporter_ids.uniq
      end
      supports_redis.smembers(key)
    end

    def supporter_count
      key = SupportTracker.supporters_key(supportable)
      supporter_ids = supportable.supporter_ids.uniq
      return if supporter_ids.empty?
      unless supports_redis.exists(key)
        supports_redis.sadd(key, supporter_ids)
        return supporter_ids.length
      end
      return supports_redis.scard(key)
    end

  end
end

