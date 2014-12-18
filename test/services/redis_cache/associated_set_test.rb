require 'test_helper'

class AssociatedSetTest < ActiveSupport::TestCase
  let (:commenters) { RedisCache::AssociatedSet.new('post:1', 'commenters') }

  describe '#add' do
    it 'adds a single member' do
      commenters.add(1)
      commenters.all.must_include '1'
    end

    it 'adds multiple members' do
      commenters.add([1,2])
      commenters.all.must_include '1'
      commenters.all.must_include '2'
    end

    it 'does not add the same member multiple times' do
      commenters.add(1)
      commenters.add(1)
      commenters.all.length.must_equal 1
    end
  end

  describe '#remove' do
    before do
      commenters.add([1, 2])
      commenters.all.must_include '1'
    end

    it 'removes a single member' do
      commenters.remove(1)
      commenters.all.wont_include '1'
    end

    it 'removes multiple members' do
      commenters.remove([1, 2])
      commenters.all.wont_include '1'
      commenters.all.wont_include '2'
    end
  end

  describe '#all' do
    it 'returns an empty set if no member has been added' do
      commenters.all.must_equal []
    end
  end

  describe '#total_count' do
    it 'matches the number of items in #all' do
      commenters.total_count.must_equal commenters.all.length

      commenters.add(1)
      commenters.total_count.must_equal commenters.all.length
    end
  end
end