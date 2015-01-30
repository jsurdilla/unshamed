module RedisCache::RedisResponseUtils
  extend ActiveSupport::Concern

  # Takes an array of type_id_pairs of the format
  # `<underscored_class_name>:<instance_id>` (e.g., user:1) and group them by
  # the underscored class name.
  def self.group_type_id_pairs(type_id_pairs)
    type_id_pairs.inject({}) do |memo, pair|
      item_type, item_id = pair.split(':')
      (memo[item_type] ||= []) << item_id
      memo
    end
  end

  # Given an array of collection of model instances, it will create a mapping
  # from type-id colon format to the actual instance.
  #
  # For example, given [[Post(1), Post(2)], [User(1)], it will produce
  # `{ "post:1" => Post(1), "post:2" => Post(2), "user:1" => User(1) }`.
  def self.type_id_pair_to_instance_mapping(*instance_collections)
    instance_collections.flatten.compact.inject({}) do |memo, item|
      memo["#{item.class.name.underscore}:#{item.id}"] = item
      memo
    end
  end

  # It takes an ordered list of type-id pairs and the actual instances that
  # correspond to the pairs and returns the instances ordered by the type-id
  # pairs.
  def self.order_instances_to_type_id_pairs(type_id_pairs, *instance_collections)
    colon_to_instance = self.type_id_pair_to_instance_mapping(*instance_collections)
    type_id_pairs.map { |pair| colon_to_instance[pair] }
  end

end
