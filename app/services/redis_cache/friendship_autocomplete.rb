module RedisCache
  class FriendshipAutocomplete
    def self.index_for_user(user)
      score_token_pairs = user.friends.map do |friend|
        [friend.first_name, friend.last_name].map do |token|
          [0, "#{token.downcase}:#{friend.id}"]
        end
      end
      key = "user#{user.id}"
      redis.del key
      redis.zadd key, score_token_pairs.flatten
    end

    def self.find(user, query)
      tokens = query.split(' ')
      key = "user#{user.id}"
      index_for_user(user) unless redis.exists key
      tokens.map do |token|
        redis.zrangebylex key, "[#{token.downcase}", "[#{token.downcase}\xff"
      end.flatten
    end

    private

    def self.redis
      return @redis if @redis
      redis_connection = Redis.new
      @redis = Redis::Namespace.new(:friends, :redis => redis_connection)
    end
  end
end
