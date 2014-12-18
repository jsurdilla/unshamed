module RedisCache
  class StruggleMembers
    include RedisCache::Utils

    delegate :add_items, :remove_items, :items, to: :@multi_group_zset

    def initialize(struggles)
      @struggles = struggles.is_a?(Array) ? struggles.sort : [struggles].flatten.sort
      @multi_group_zset = MultiGroupKeyZset.new('struggles', 'members', struggles, self)
    end

    def change_member_struggles(user_id, new_struggles)
      @multi_group_zset.reclassify(User.where(id: user_id).all, new_struggles)
    end

    def initial_items(struggle)
      User.joins([:member_profile]).onboarded.where("? = ANY(member_profiles.struggles)", struggle).all
    end
  end
end