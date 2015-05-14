require 'test_helper'

class MockLoader < Struct.new(:items)
  def initial_items(group)
    items
  end
end

class MultiGroupKeyZsetTest < ActiveSupport::TestCase
  include RedisCache::Utils

  let(:loader) { MiniTest::Mock.new }
  let(:struggles_items) { RedisCache::MultiGroupKeyZset.new('struggles', 'items', ['anxiety', 'depression'], loader) }

  before(:each) do
    RedisCache.redis.flushall
  end

  describe 'initialization' do
    it 'raises exception when group_name is mssing' do
      lambda { RedisCache::MultiGroupKeyZset.new('', 'items', ['anxiety', 'depression'], loader) }.must_raise RuntimeError
    end

    it 'raises exception when group_name is mssing' do
      lambda { RedisCache::MultiGroupKeyZset.new('struggles', '', ['anxiety', 'depression'], loader) }.must_raise RuntimeError
    end

    it 'raises exception when group_name is mssing' do
      lambda { RedisCache::MultiGroupKeyZset.new('struggles', 'items', [], loader) }.must_raise RuntimeError
    end
  end

  describe '#add_items' do
    it 'pre-loads individual groups that have not been initialized' do
      post_for_preload = FactoryGirl.create(:post)
      loader.expect(:initial_items, [post_for_preload], ['anxiety'])
      loader.expect(:initial_items, [post_for_preload], ['depression'])

      struggles_items.uninitialized_groups == ['anxiety', 'depression']
      struggles_items.add_items(FactoryGirl.create(:post))
      
      ['anxiety', 'depression'].each do |s|
        struggle_items = RedisCache::MultiGroupKeyZset.new('struggles', 'items', [s], loader)
        struggle_items.items(1).must_include to_zset_member_string(post_for_preload)
        struggle_items.items(1).length.must_equal 2
      end
    end

    it 'pre-loads aggregate if it has not been initialized' do
      post_for_preload = FactoryGirl.create(:post)
      loader.expect(:initial_items, [post_for_preload], ['anxiety'])
      loader.expect(:initial_items, [post_for_preload], ['depression'])

      struggles_items.add_items(FactoryGirl.create(:post))

      struggles_items.items(1).must_include to_zset_member_string(post_for_preload)
    end

    it 'adds single item to individual groups' do
      loader.expect(:initial_items, [], ['anxiety'])
      loader.expect(:initial_items, [], ['depression'])

      post1 = FactoryGirl.create(:post)
      struggles_items.add_items(post1)

      ['anxiety', 'depression'].each do |s|
        struggle_items = RedisCache::MultiGroupKeyZset.new('struggles', 'items', [s], loader)
        struggle_items.items(1).must_include to_zset_member_string(post1)
        struggle_items.items(1).length.must_equal 1
      end
    end

    it 'adds a single item to aggregate' do
      loader.expect(:initial_items, [], ['anxiety'])
      loader.expect(:initial_items, [], ['depression'])

      post1 = FactoryGirl.create(:post)
      struggles_items.add_items(post1)
      struggles_items.items(1).must_include to_zset_member_string(post1)
      struggles_items.items(1).length.must_equal 1
    end

    it 'adds multiple items to individual groups' do
      loader.expect(:initial_items, [], ['anxiety'])
      loader.expect(:initial_items, [], ['depression'])

      post1, post2 = FactoryGirl.create(:post), FactoryGirl.create(:post)
      struggles_items.add_items([post1, post2])

      ['anxiety', 'depression'].each do |s|
        struggle_items = RedisCache::MultiGroupKeyZset.new('struggles', 'items', [s], loader)
        struggle_items.items(1).must_include to_zset_member_string(post1)
        struggle_items.items(1).must_include to_zset_member_string(post2)
        struggle_items.items(1).length.must_equal 2
      end
    end

    it 'adds multiple items to aggregate' do
      loader.expect(:initial_items, [], ['anxiety'])
      loader.expect(:initial_items, [], ['depression'])

      post1, post2 = FactoryGirl.create(:post), FactoryGirl.create(:post)
      struggles_items.add_items([post1, post2])

      struggles_items.items(1).must_include to_zset_member_string(post1)
      struggles_items.items(1).must_include to_zset_member_string(post2)
      struggles_items.items(1).length.must_equal 2
    end
  end

  describe '#items' do
    it 'pre-loads individual groups' do
      post_for_preload = FactoryGirl.create(:post)
      loader.expect(:initial_items, [post_for_preload], ['anxiety'])
      loader.expect(:initial_items, [post_for_preload], ['depression'])

      ['anxiety', 'depression'].each do |s|
        struggle_items = RedisCache::MultiGroupKeyZset.new('struggles', 'items', [s], loader)
        struggle_items.items(1).must_include to_zset_member_string(post_for_preload)
        struggle_items.items(1).length.must_equal 1
      end
    end

    it 'pre-loads aggregate' do
      post_for_preload = FactoryGirl.create(:post)
      loader.expect(:initial_items, [post_for_preload], ['anxiety'])
      loader.expect(:initial_items, [post_for_preload], ['depression'])

      struggles_items.uninitialized_groups == ['anxiety', 'depression']
      struggles_items.items(1).must_include to_zset_member_string(post_for_preload)
      struggles_items.items(1).length.must_equal 1
    end
  end

  describe '#remove_items' do
    it 'does not do anything if the individual group is uninitialized' do
      loader.expect(:initial_items, [], ['anxiety'])
      loader.expect(:initial_items, [], ['depression'])

      post1, post2 = FactoryGirl.create(:post), FactoryGirl.create(:post)

      anxiety_items = RedisCache::MultiGroupKeyZset.new('struggles', 'items', ['anxiety'], loader)
      anxiety_items.add_items([post1, post2])

      struggles_items.uninitialized_groups.must_equal ['depression']
      struggles_items.remove_items(post1)

      RedisCache.redis.exists(struggles_items.single_group_key('depression')).must_equal false
      RedisCache.redis.exists(struggles_items.aggregate_key).must_equal false
    end

    it 'removes it from individual groups that are initialized' do
      loader.expect(:initial_items, [], ['anxiety'])
      loader.expect(:initial_items, [], ['depression'])

      post1, post2 = FactoryGirl.create(:post), FactoryGirl.create(:post)
      struggles_items.add_items([post1, post2])
      ['anxiety', 'depression'].each do |s|
        struggle_items = RedisCache::MultiGroupKeyZset.new('struggles', 'items', [s], loader)
        struggle_items.items(1).must_include to_zset_member_string(post1)
        struggle_items.items(1).must_include to_zset_member_string(post2)
        struggle_items.items(1).length.must_equal 2
      end

      struggles_items.remove_items(post1)
      ['anxiety', 'depression'].each do |s|
        struggle_items = RedisCache::MultiGroupKeyZset.new('struggles', 'items', [s], loader)
        struggle_items.items(1).wont_include to_zset_member_string(post1)
        struggle_items.items(1).must_include to_zset_member_string(post2)
        struggle_items.items(1).length.must_equal 1
      end
    end
  end

  describe '#reclassify' do
    it 'keeps the zsets if the destination groups are the same' do
      loader.expect(:initial_items, [], ['anxiety'])
      loader.expect(:initial_items, [], ['depression'])

      post1, post2 = FactoryGirl.create(:post), FactoryGirl.create(:post)
      struggles_items.add_items([post1, post2])

      struggles_items.reclassify([post1], ['anxiety', 'depression'])
      struggles_items.items(1).must_include to_zset_member_string(post1)
      struggles_items.items(1).length.must_equal 2
    end

    it 'removes items from the individual groups if the group is not in the destination set' do
      loader.expect(:initial_items, [], ['anxiety'])
      loader.expect(:initial_items, [], ['depression'])

      post1, post2 = FactoryGirl.create(:post), FactoryGirl.create(:post)
      struggles_items.add_items([post1, post2])

      struggle_items = RedisCache::MultiGroupKeyZset.new('struggles', 'items', ['depression'], loader)
      struggle_items.items(1).must_include to_zset_member_string(post1)

      struggles_items.reclassify([post1], ['anxiety', 'ocd'])
      struggle_items.items(1).wont_include to_zset_member_string(post1)
    end

    it 'removes items from the aggregate group if the source and groups do not intersect at any group' do
      loader.expect(:initial_items, [], ['anxiety'])
      loader.expect(:initial_items, [], ['depression'])

      post1, post2 = FactoryGirl.create(:post), FactoryGirl.create(:post)
      struggles_items.add_items([post1, post2])

      struggles_items.items(1).sort.must_equal to_zset_member_strings([post1, post2].sort)
      struggles_items.reclassify([post1], ['addiction', 'ocd'])
      struggles_items.items(1).sort.must_equal [to_zset_member_string(post2)]
    end

    it 'keeps the items if at least one of the component groups intersect' do
      loader.expect(:initial_items, [], ['anxiety'])
      loader.expect(:initial_items, [], ['depression'])

      post1, post2 = FactoryGirl.create(:post), FactoryGirl.create(:post)
      struggles_items.add_items([post1, post2])

      struggles_items.items(1).sort.must_equal to_zset_member_strings([post1, post2].sort)
      struggles_items.reclassify([post1], ['anxiety', 'ocd'])
      struggles_items.items(1).sort.must_equal to_zset_member_strings([post1, post2].sort)
    end

    it 'adds the items to the individual destination group that is not in the source' do
      loader.expect(:initial_items, [], ['anxiety'])
      loader.expect(:initial_items, [], ['depression'])
      loader.expect(:initial_items, [], ['ocd'])

      post1, post2 = FactoryGirl.create(:post), FactoryGirl.create(:post)
      struggles_items.add_items([post1, post2])

      struggles_items.items(1).sort.must_equal to_zset_member_strings([post1, post2].sort)
      struggles_items.reclassify([post1], ['anxiety', 'ocd'])

      struggle_items = RedisCache::MultiGroupKeyZset.new('struggles', 'items', ['ocd'], loader)
      struggle_items.items(1).must_include to_zset_member_string(post1)
    end

    it 'adds the items to the destination aggregate group' do
      loader.expect(:initial_items, [], ['anxiety'])
      loader.expect(:initial_items, [], ['depression'])
      loader.expect(:initial_items, [], ['ocd'])

      post1, post2 = FactoryGirl.create(:post), FactoryGirl.create(:post)
      struggles_items.add_items([post1, post2])

      struggles_items.items(1).sort.must_equal to_zset_member_strings([post1, post2].sort)
      struggles_items.reclassify([post1], ['anxiety', 'ocd'])

      struggle_items = RedisCache::MultiGroupKeyZset.new('struggles', 'items', ['anxiety', 'ocd'], loader)
      struggle_items.items(1).must_include to_zset_member_string(post1)
    end

    it 'leaves the destination group unchanged if there are no items' do
      loader.expect(:initial_items, [], ['anxiety'])
      loader.expect(:initial_items, [], ['depression'])
      loader.expect(:initial_items, [], ['ocd'])

      post1, post2 = FactoryGirl.create(:post), FactoryGirl.create(:post)
      struggles_items.add_items([post1, post2])
      struggles_items.items(1).sort.must_equal to_zset_member_strings([post1, post2].sort)
      struggles_items.reclassify([], ['ocd'])

      ocd_items = RedisCache::MultiGroupKeyZset.new('struggles', 'items', ['ocd'], loader)
      ocd_items.items(1).sort.must_be_empty
    end

    it 'removes items from related multi-group keys if the items are gone from all their constituent keys' do
      loader = MockLoader.new([])
      struggles_items = RedisCache::MultiGroupKeyZset.new('struggles', 'items', ['anxiety', 'depression'], loader) 

      post1, post2 = FactoryGirl.create(:post), FactoryGirl.create(:post)

      anxiety_items = RedisCache::MultiGroupKeyZset.new('struggles', 'items', ['anxiety'], loader)
      anxiety_items.add_items([post1])
      struggles_items.items(1).must_include to_zset_member_string(post1)

      anxiety_items.reclassify([post1], ['ocd'])
      struggles_items.items(1).wont_include to_zset_member_string(post1)
    end

    it 'keeps the items in related multi-group keys if one of the constituent keys still have the items' do
      loader = MockLoader.new([])
      struggles_items = RedisCache::MultiGroupKeyZset.new('struggles', 'items', ['anxiety', 'depression'], loader) 

      post1, post2 = FactoryGirl.create(:post), FactoryGirl.create(:post)

      anxiety_items = RedisCache::MultiGroupKeyZset.new('struggles', 'items', ['anxiety'], loader)
      anxiety_items.add_items([post1])
      struggles_items.items(1).must_include to_zset_member_string(post1)

      anxiety_items.reclassify([post1], ['depression'])
      struggles_items.items(1).must_include to_zset_member_string(post1)
    end

    it 'adds the items to related aggregates that these items were not previously a part of prior to the reclassification'
  end
end