module RedisCache
  class StruggleResources
    delegate :add_items, :remove_items, :items, to: :@multi_group_zset

    def initialize(struggles)
      @struggles = struggles.is_a?(Array) ? struggles.sort : [struggles].flatten.sort
      @multi_group_zset = MultiGroupKeyZset.new('struggles', 'resources', struggles, self)
    end

    def change_resource_struggles(resource_ids, new_struggles)
      @multi_group_zset.reclassify(Resource.where(id: resource_ids), new_struggles)
    end

    def initial_items(struggle)
      resources = Resource.where("? = ANY(struggles)", struggle).all
    end
  end
end