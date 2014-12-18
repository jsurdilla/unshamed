module Timeline
  module Utils

    SECONDS_IN_DAY = 24 * 60 * 60
    INCEPTION      = Date.parse('2015-01-01').to_time.to_i

    def to_zset_pair(item, scoring=:created_at)
      [ score(item, scoring), to_zset_member_string(item) ]
    end

    def to_zset_pairs(items, scoring=:created_at)
      items.map { |item| to_zset_pair(item, scoring) }
    end

    def to_zset_member_string(item)
      "#{item.class.name.underscore}:#{item.id}"
    end

    def to_zset_member_strings(items)
      items.map { |item| to_zset_member_string(item) }
    end

    private

    def score(item, scoring)
      if scoring === :created_at
        return created_at_scoring(item)
      else
        1
      end
    end

    def created_at_scoring(item)
      days_since_inception(item.created_at).round(2)
    end

    def days_since_inception(time)
      (time.to_i - INCEPTION).to_f / SECONDS_IN_DAY
    end

  end
end
