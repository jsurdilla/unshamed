module RedisCache
  # CommentTracker manages comment information for commentable objects.
  class CommentTracker
    include Utils

    attr_reader :commentable

    # The base key from which all comments-related redis keys are based from.
    # Its format is `posts:1:comments`.
    def self.base_key(commentable)
      "#{commentable.class.name.underscore}:#{commentable.id}"
    end

    # Key for all the commenters on the object. Its format is
    # `comments:posts:1:commenters`
    def self.commenters_key(commentable)
      "#{base_key(commentable)}:commenters"
    end

    # Initialize every tracker with a commentable object. A commentable object
    # must respond to `commenter_ids`.
    def initialize(commentable)
      @commentable = commentable
    end

    # Add given user_id as a commenter. If it's the first user, it initializes
    # the object by adding all existing commenters.
    def add_commenter(user_id)
      key = CommentTracker.commenters_key(commentable)
      unless comments_redis.exists(key)
        comments_redis.sadd(key, commentable.commenter_ids.uniq)
      end
      comments_redis.sadd(key, user_id)
    end

    def remove_commenter(user_id)
    end

    # Returns all commenter IDs. If they key doesn't exist, it initializes the
    # object by adding all existing commenters.
    def commenter_ids
      key = CommentTracker.commenters_key(commentable)
      unless comments_redis.exists(key)
        comments_redis.sadd(key, commentable.commenter_ids.uniq)
        return commentable.commenter_ids.uniq
      end
      comments_redis.smembers(key)
    end

  end
end
