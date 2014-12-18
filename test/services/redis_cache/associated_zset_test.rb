require 'test_helper'

class AssociatedZsetTest < ActiveSupport::TestCase
  let (:items) { RedisCache::AssociatedZset.new('post:1', 'items') }

  before do
    @r = RedisCache.redis
    @r.flushall
  end

  describe '#add' do
    it 'adds a single member' do
      items.add([10, 'a'])
      items.members.must_include 'a'
    end

    it 'adds multiple members' do
      items.add([[10, 'a'], [20, 'b']])
      items.members.must_include 'a'
      items.members.must_include 'b'
    end

    it 'does not add the same member multiple times' do
      items.add([10, 'a'])
      items.add([10, 'a'])
      items.members.length.must_equal 1
    end
  end

  describe '#remove' do
    before do
      items.add([10, 'a'])
      items.members.must_include 'a'
    end

    it 'removes a single member' do
      items.remove('a')
      items.members.wont_include 'a'
    end

    it 'removes multiple members' do
      items.remove(['a', 'b'])
      items.members.wont_include 'a'
      items.members.wont_include 'b'
    end
  end

  describe '#members' do
    it 'returns an empty set if no member has been added' do
      items.members.must_equal []
    end
  end
end