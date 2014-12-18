require 'test_helper'

class RedisCache::HomeTimelineTest < ActiveSupport::TestCase
  before do
    @redis = RedisCache.redis
    @redis.flushall
  end

  describe '.items_key' do
    it 'should work with a single struggle' do
      RedisCache::HomeTimeline.items_key(['ocd']).must_equal 'groups:ocd:home_timeline'
    end

    it 'should work with multiple struggles' do
      RedisCache::HomeTimeline.items_key(['ocd', 'anxiety']).must_equal 'groups:anxiety-ocd:home_timeline'
    end
  end

  describe '.relevant_items_keys with single struggle' do
    it 'should include home_timeline keys for the same struggle' do
      @redis.set 'groups:anxiety:home_timeline', 0
      RedisCache::HomeTimeline.relevant_items_keys(['anxiety']).must_include 'groups:anxiety:home_timeline'
    end

    it 'should not include home_timeline keys for a different struggle' do
      @redis.set 'groups:anxiety:home_timeline', 0
      RedisCache::HomeTimeline.relevant_items_keys(['ocd']).wont_include 'groups:anxiety:home_timeline'
    end

    it 'should not include non-home_timeline keys (false positive)' do
      @redis.set 'groups:anxiety:other_timeline', 0
      RedisCache::HomeTimeline.relevant_items_keys(['anxiety']).wont_include 'groups:anxiety:other_timeline'
    end
  end

  describe '.relevant_items_keys with multiple struggles' do
    it 'should include home_timeline keys for each of the individual struggle' do
      @redis.set 'groups:anxiety:home_timeline', 0
      @redis.set 'groups:ocd:home_timeline', 0
      RedisCache::HomeTimeline.relevant_items_keys(['anxiety', 'ocd']).must_include 'groups:anxiety:home_timeline'
      RedisCache::HomeTimeline.relevant_items_keys(['anxiety', 'ocd']).must_include 'groups:ocd:home_timeline'
    end

    it 'should include home_timeline keys for the aggregate of the struggles' do
      @redis.set 'groups:anxiety-ocd:home_timeline', 0
      RedisCache::HomeTimeline.relevant_items_keys(['anxiety', 'ocd']).must_include 'groups:anxiety-ocd:home_timeline'
    end

    it 'should include home_timeline keys that would match if each of the struggles were to be ran individually' do
      @redis.set 'groups:anxiety-foobar-ocd:home_timeline', 0
      @redis.set 'groups:anxiety-foo:home_timeline', 0
      @redis.set 'groups:ocd-bar:home_timeline', 0

      RedisCache::HomeTimeline.relevant_items_keys(['anxiety', 'ocd']).must_include 'groups:anxiety-foobar-ocd:home_timeline'
      RedisCache::HomeTimeline.relevant_items_keys(['anxiety', 'ocd']).must_include 'groups:anxiety-foo:home_timeline'
      RedisCache::HomeTimeline.relevant_items_keys(['anxiety', 'ocd']).must_include 'groups:ocd-bar:home_timeline'
    end
  end

  describe '#add_items with for a timeline with a single struggle as argument' do
    let(:user_with_ocd) { FactoryGirl.create(:member_profile, :ocd).user }
    let(:user_with_anxiety) { FactoryGirl.create(:member_profile, :anxiety).user }

    before do
      @post_ocd1     = FactoryGirl.create(:post, user: user_with_ocd)
      @post_ocd2     = FactoryGirl.create(:post, user: user_with_ocd)
      @post_anxiety1 = FactoryGirl.create(:post, user: user_with_anxiety)
      @post_anxiety2 = FactoryGirl.create(:post, user: user_with_anxiety)

      @journal_entry_ocd1     = FactoryGirl.create(:journal_entry, :public, user: user_with_ocd)
      @journal_entry_ocd2     = FactoryGirl.create(:journal_entry, :public, user: user_with_ocd)
      @journal_entry_ocd3     = FactoryGirl.create(:journal_entry, user: user_with_ocd)
      @journal_entry_anxiety1 = FactoryGirl.create(:journal_entry, :public, user: user_with_anxiety)
      @journal_entry_anxiety2 = FactoryGirl.create(:journal_entry, :public, user: user_with_anxiety)
      @journal_entry_anxiety3 = FactoryGirl.create(:journal_entry, user: user_with_anxiety)
    end

    it 'should initialize the key with posts from users with that struggle' do
      @redis.flushall

      ht_anxiety = RedisCache::HomeTimeline.new('anxiety')
      ht_anxiety.add_items(@post_anxiety1)

      timeline_members = ht_anxiety.redis.zrange 'groups:anxiety:home_timeline', 0, -1
      timeline_members.sort.must_include "post:#{@post_anxiety1.id}"
      timeline_members.sort.must_include "post:#{@post_anxiety2.id}"
    end

    it 'should initialize the key with public journal entries from users with that struggle' do
      @redis.flushall

      ht_anxiety = RedisCache::HomeTimeline.new('anxiety')
      ht_anxiety.add_items(@journal_entry_anxiety1)

      timeline_members = ht_anxiety.redis.zrange 'groups:anxiety:home_timeline', 0, -1
      timeline_members.sort.must_include "journal_entry:#{@journal_entry_anxiety1.id}"
      timeline_members.sort.must_include "journal_entry:#{@journal_entry_anxiety2.id}"
      timeline_members.sort.wont_include "journal_entry:#{@journal_entry_anxiety3.id}"
    end

    it "should add post argument regardless of its associated user's struggles" do
      @redis.flushall

      ht_anxiety = RedisCache::HomeTimeline.new('anxiety')
      ht_anxiety.add_items(@post_ocd1)

      timeline_members = ht_anxiety.redis.zrange 'groups:anxiety:home_timeline', 0, -1
      timeline_members.sort.must_include "post:#{@post_ocd1.id}"
    end

    it 'should add the item if the key already exists' do
      @redis.flushall

      ht_anxiety = RedisCache::HomeTimeline.new('anxiety')
      ht_anxiety.add_items(@post_anxiety1)

      new_post = FactoryGirl.create(:post, user: FactoryGirl.build(:member_profile).user)
      ht_anxiety.redis.zrange('groups:anxiety:home_timeline', 0, -1).wont_include "post:#{new_post.id}"
      ht_anxiety.add_items(new_post)
      ht_anxiety.redis.zrange('groups:anxiety:home_timeline', 0, -1).must_include "post:#{new_post.id}"
    end

    it 'should add the item to related keys' do
      @redis.flushall

      ht_anxiety = RedisCache::HomeTimeline.new('anxiety')
      ht_anxiety.add_items(@post_anxiety1)

      related_key = 'groups:anxiety-foo:home_timeline'
      ht_anxiety.redis.zadd related_key, 1.0, 'bar'

      new_post = FactoryGirl.create(:post, user: FactoryGirl.build(:member_profile).user)
      ht_anxiety.redis.zrange(related_key, 0, -1).wont_include "post:#{new_post.id}"
      ht_anxiety.add_items(new_post)
      ht_anxiety.redis.zrange(related_key, 0, -1).must_include "post:#{new_post.id}"
    end
  end

  describe '#add_items with for a timeline with multiple struggles' do
    let(:user_with_ocd) { FactoryGirl.create(:member_profile, :ocd).user }
    let(:user_with_anxiety) { FactoryGirl.create(:member_profile, :anxiety).user }
    let(:user_with_depression) { FactoryGirl.create(:member_profile, :depression).user }

    before do
      @post_ocd1     = FactoryGirl.create(:post, user: user_with_ocd)
      @post_ocd2     = FactoryGirl.create(:post, user: user_with_ocd)
      @post_anxiety1 = FactoryGirl.create(:post, user: user_with_anxiety)
      @post_anxiety2 = FactoryGirl.create(:post, user: user_with_anxiety)
      @post_depression1 = FactoryGirl.create(:post, user: user_with_depression)
      @post_depression2 = FactoryGirl.create(:post, user: user_with_depression)

      @journal_entry_ocd1     = FactoryGirl.create(:journal_entry, :public, user: user_with_ocd)
      @journal_entry_ocd2     = FactoryGirl.create(:journal_entry, :public, user: user_with_ocd)
      @journal_entry_ocd3     = FactoryGirl.create(:journal_entry, user: user_with_ocd)
      @journal_entry_anxiety1 = FactoryGirl.create(:journal_entry, :public, user: user_with_anxiety)
      @journal_entry_anxiety2 = FactoryGirl.create(:journal_entry, :public, user: user_with_anxiety)
      @journal_entry_anxiety3 = FactoryGirl.create(:journal_entry, user: user_with_anxiety)
      @journal_entry_depression1 = FactoryGirl.create(:journal_entry, :public, user: user_with_depression)
      @journal_entry_depression2 = FactoryGirl.create(:journal_entry, :public, user: user_with_depression)
      @journal_entry_depression3 = FactoryGirl.create(:journal_entry, user: user_with_depression)
    end

    it 'should initialize each constituent key with posts from users with that struggle' do
      @redis.flushall

      ht_anxiety_ocd = RedisCache::HomeTimeline.new(['anxiety', 'ocd'])
      ht_anxiety_ocd.add_items(@post_anxiety1)

      timeline_members = ht_anxiety_ocd.redis.zrange 'groups:anxiety:home_timeline', 0, -1
      timeline_members.sort.must_include "post:#{@post_anxiety1.id}"
      timeline_members.sort.must_include "post:#{@post_anxiety2.id}"

      timeline_members = ht_anxiety_ocd.redis.zrange 'groups:ocd:home_timeline', 0, -1
      timeline_members.sort.must_include "post:#{@post_ocd1.id}"
      timeline_members.sort.must_include "post:#{@post_ocd2.id}"
    end

    it 'should initialize each constituent key with public journal entries from users with that struggle' do
      @redis.flushall

      ht_anxiety_ocd = RedisCache::HomeTimeline.new(['anxiety', 'ocd'])
      ht_anxiety_ocd.add_items(@post_anxiety1)

      timeline_members = ht_anxiety_ocd.redis.zrange 'groups:anxiety:home_timeline', 0, -1
      timeline_members.sort.must_include "journal_entry:#{@journal_entry_anxiety1.id}"
      timeline_members.sort.must_include "journal_entry:#{@journal_entry_anxiety2.id}"
      timeline_members.sort.wont_include "journal_entry:#{@journal_entry_anxiety3.id}"

      timeline_members = ht_anxiety_ocd.redis.zrange 'groups:ocd:home_timeline', 0, -1
      timeline_members.sort.must_include "journal_entry:#{@journal_entry_ocd1.id}"
      timeline_members.sort.must_include "journal_entry:#{@journal_entry_ocd2.id}"
      timeline_members.sort.wont_include "journal_entry:#{@journal_entry_ocd3.id}"
    end

    it 'should not initialize each constituent key with posts from users without that struggle' do
      @redis.flushall

      ht_anxiety_ocd = RedisCache::HomeTimeline.new(['anxiety', 'ocd'])
      ht_anxiety_ocd.add_items(@post_anxiety1)

      timeline_members = ht_anxiety_ocd.redis.zrange 'groups:anxiety:home_timeline', 0, -1
      timeline_members.sort.wont_include "post:#{@post_depression1.id}"
      timeline_members.sort.wont_include "post:#{@post_depression2.id}"
    end

    it 'should not initialize each constituent key with journal entries from users without that struggle' do
      @redis.flushall

      ht_anxiety_ocd = RedisCache::HomeTimeline.new(['anxiety', 'ocd'])
      ht_anxiety_ocd.add_items(@post_anxiety1)

      timeline_members = ht_anxiety_ocd.redis.zrange 'groups:anxiety:home_timeline', 0, -1
      timeline_members.sort.wont_include "post:#{@journal_entry_depression1.id}"
      timeline_members.sort.wont_include "post:#{@journal_entry_depression2.id}"
    end

    it 'should initialize the aggregate key with posts from users with these struggles' do
      @redis.flushall

      ht_anxiety_ocd = RedisCache::HomeTimeline.new(['anxiety', 'ocd'])
      ht_anxiety_ocd.add_items(@post_anxiety1)

      timeline_members = ht_anxiety_ocd.redis.zrange 'groups:anxiety-ocd:home_timeline', 0, -1
      timeline_members.sort.must_include "post:#{@post_anxiety1.id}"
      timeline_members.sort.must_include "post:#{@post_anxiety2.id}"
      timeline_members.sort.must_include "post:#{@post_ocd1.id}"
      timeline_members.sort.must_include "post:#{@post_ocd2.id}"
    end

    it 'should initialize the aggregate key with journal_entries from users with these struggles' do
      @redis.flushall

      ht_anxiety_ocd = RedisCache::HomeTimeline.new(['anxiety', 'ocd'])
      ht_anxiety_ocd.add_items(@post_anxiety1)

      timeline_members = ht_anxiety_ocd.redis.zrange 'groups:anxiety-ocd:home_timeline', 0, -1
      timeline_members.sort.must_include "journal_entry:#{@journal_entry_anxiety1.id}"
      timeline_members.sort.must_include "journal_entry:#{@journal_entry_anxiety2.id}"
      timeline_members.sort.wont_include "journal_entry:#{@journal_entry_anxiety3.id}"
      timeline_members.sort.must_include "journal_entry:#{@journal_entry_ocd1.id}"
      timeline_members.sort.must_include "journal_entry:#{@journal_entry_ocd2.id}"
      timeline_members.sort.wont_include "journal_entry:#{@journal_entry_ocd3.id}"
    end

    it 'should not initialize the aggregate key with posts from users without these struggles' do
      @redis.flushall

      ht_anxiety_ocd = RedisCache::HomeTimeline.new(['anxiety', 'ocd'])
      ht_anxiety_ocd.add_items(@post_anxiety1)

      timeline_members = ht_anxiety_ocd.redis.zrange 'groups:anxiety-ocd:home_timeline', 0, -1
      timeline_members.sort.wont_include "post:#{@post_depression1.id}"
      timeline_members.sort.wont_include "post:#{@post_depression2.id}"
    end

    it 'should not initialize the aggregate key with journal entries from users without these struggles' do
      @redis.flushall

      ht_anxiety_ocd = RedisCache::HomeTimeline.new(['anxiety', 'ocd'])
      ht_anxiety_ocd.add_items(@post_anxiety1)

      timeline_members = ht_anxiety_ocd.redis.zrange 'groups:anxiety-ocd:home_timeline', 0, -1
      timeline_members.sort.wont_include "journal_entry:#{@journal_entry_depression1.id}"
      timeline_members.sort.wont_include "journal_entry:#{@journal_entry_depression2.id}"
      timeline_members.sort.wont_include "journal_entry:#{@journal_entry_depression3.id}"
    end

    it "should add post argument to constituent key regardless of its associated user's struggles" do
      @redis.flushall

      ht_anxiety_ocd = RedisCache::HomeTimeline.new(['anxiety', 'ocd'])
      ht_anxiety_ocd.add_items(@post_anxiety1)

      new_post = FactoryGirl.create(:post, user: FactoryGirl.build(:member_profile).user)
      ht_anxiety_ocd.redis.zrange('groups:anxiety:home_timeline', 0, -1).wont_include "post:#{new_post.id}"
      ht_anxiety_ocd.redis.zrange('groups:ocd:home_timeline', 0, -1).wont_include "post:#{new_post.id}"
      ht_anxiety_ocd.add_items(new_post)
      ht_anxiety_ocd.redis.zrange('groups:anxiety:home_timeline', 0, -1).must_include "post:#{new_post.id}"
      ht_anxiety_ocd.redis.zrange('groups:ocd:home_timeline', 0, -1).must_include "post:#{new_post.id}"
    end

    it "should add post argument to aggregate key regardless of its associated user's struggles" do
      @redis.flushall

      ht_anxiety_ocd = RedisCache::HomeTimeline.new(['anxiety', 'ocd'])
      ht_anxiety_ocd.add_items(@post_anxiety1)

      new_post = FactoryGirl.create(:post, user: FactoryGirl.build(:member_profile).user)
      ht_anxiety_ocd.redis.zrange('groups:anxiety-ocd:home_timeline', 0, -1).wont_include "post:#{new_post.id}"
      ht_anxiety_ocd.add_items(new_post)
      ht_anxiety_ocd.redis.zrange('groups:anxiety-ocd:home_timeline', 0, -1).must_include "post:#{new_post.id}"
    end
  end

  describe '#remove_items with a single item' do
    let(:user_with_ocd) { FactoryGirl.create(:member_profile, :ocd).user }
    let(:user_with_anxiety) { FactoryGirl.create(:member_profile, :anxiety).user }
    let(:user_with_depression) { FactoryGirl.create(:member_profile, :depression).user }

    before do
      @post_ocd1                 = FactoryGirl.create(:post, user: user_with_ocd)
      @post_ocd2                 = FactoryGirl.create(:post, user: user_with_ocd)
      @post_anxiety1             = FactoryGirl.create(:post, user: user_with_anxiety)
      @post_anxiety2             = FactoryGirl.create(:post, user: user_with_anxiety)
      @post_depression1          = FactoryGirl.create(:post, user: user_with_depression)
      @post_depression2          = FactoryGirl.create(:post, user: user_with_depression)

      @journal_entry_ocd1        = FactoryGirl.create(:journal_entry, :public, user: user_with_ocd)
      @journal_entry_ocd2        = FactoryGirl.create(:journal_entry, :public, user: user_with_ocd)
      @journal_entry_ocd3        = FactoryGirl.create(:journal_entry, user: user_with_ocd)
      @journal_entry_anxiety1    = FactoryGirl.create(:journal_entry, :public, user: user_with_anxiety)
      @journal_entry_anxiety2    = FactoryGirl.create(:journal_entry, :public, user: user_with_anxiety)
      @journal_entry_depression1 = FactoryGirl.create(:journal_entry, :public, user: user_with_depression)
      @journal_entry_depression2 = FactoryGirl.create(:journal_entry, :public, user: user_with_depression)
    end

    it 'should delete the item' do
      @redis.flushall

      ht_anxiety_ocd = RedisCache::HomeTimeline.new(['anxiety'])
      ht_anxiety_ocd.add_items(@post_anxiety1)

      timeline_members = ht_anxiety_ocd.redis.zrange 'groups:anxiety:home_timeline', 0, -1
      timeline_members.sort.must_include to_zset_member_string(@post_anxiety1)
      ht_anxiety_ocd.remove_items(@post_anxiety1)
      timeline_members = ht_anxiety_ocd.redis.zrange 'groups:anxiety:home_timeline', 0, -1
      timeline_members.sort.wont_include to_zset_member_string(@post_anxiety1)
    end

    it 'should not delete other items' do
      @redis.flushall

      ht_anxiety_ocd = RedisCache::HomeTimeline.new(['anxiety'])
      ht_anxiety_ocd.add_items(@post_anxiety1)
      ht_anxiety_ocd.add_items(@post_anxiety2)

      timeline_members = ht_anxiety_ocd.redis.zrange 'groups:anxiety:home_timeline', 0, -1
      timeline_members.sort.must_include to_zset_member_string(@post_anxiety2)
      ht_anxiety_ocd.remove_items(@post_anxiety1)
      timeline_members = ht_anxiety_ocd.redis.zrange 'groups:anxiety:home_timeline', 0, -1
      timeline_members.sort.must_include to_zset_member_string(@post_anxiety2)
    end

    it 'should delete the item from related keys' do
      @redis.flushall

      ht_anxiety = RedisCache::HomeTimeline.new(['anxiety'])
      ht_anxiety.add_items(@post_anxiety1)
      ht_anxiety.add_items(@post_anxiety2)

      dupe_zset(@redis, 'groups:anxiety-ocd:home_timeline', [1, 'groups:anxiety:home_timeline'])

      timeline_members = ht_anxiety.redis.zrange 'groups:anxiety-ocd:home_timeline', 0, -1
      timeline_members.sort.must_include to_zset_member_string(@post_anxiety1)
      ht_anxiety.remove_items(@post_anxiety1)
      timeline_members = ht_anxiety.redis.zrange 'groups:anxiety-ocd:home_timeline', 0, -1
      timeline_members.sort.wont_include to_zset_member_string(@post_anxiety1)
    end
  end

  describe '#remove_items with multiple items' do
    let(:user_with_ocd) { FactoryGirl.create(:member_profile, :ocd).user }
    let(:user_with_anxiety) { FactoryGirl.create(:member_profile, :anxiety).user }
    let(:user_with_depression) { FactoryGirl.create(:member_profile, :depression).user }

    before do
      @post_ocd1                 = FactoryGirl.create(:post, user: user_with_ocd)
      @post_ocd2                 = FactoryGirl.create(:post, user: user_with_ocd)
      @post_anxiety1             = FactoryGirl.create(:post, user: user_with_anxiety)
      @post_anxiety2             = FactoryGirl.create(:post, user: user_with_anxiety)
      @post_depression1          = FactoryGirl.create(:post, user: user_with_depression)
      @post_depression2          = FactoryGirl.create(:post, user: user_with_depression)

      @journal_entry_ocd1        = FactoryGirl.create(:journal_entry, :public, user: user_with_ocd)
      @journal_entry_ocd2        = FactoryGirl.create(:journal_entry, :public, user: user_with_ocd)
      @journal_entry_ocd3        = FactoryGirl.create(:journal_entry, user: user_with_ocd)
      @journal_entry_anxiety1    = FactoryGirl.create(:journal_entry, :public, user: user_with_anxiety)
      @journal_entry_anxiety2    = FactoryGirl.create(:journal_entry, :public, user: user_with_anxiety)
      @journal_entry_depression1 = FactoryGirl.create(:journal_entry, :public, user: user_with_depression)
      @journal_entry_depression2 = FactoryGirl.create(:journal_entry, :public, user: user_with_depression)
    end

    it 'should delete all items' do
      @redis.flushall

      ht_anxiety = RedisCache::HomeTimeline.new(['anxiety'])
      ht_anxiety.add_items(@post_anxiety1)
      ht_anxiety.add_items(@post_anxiety2)

      timelines_must_include(['groups:anxiety:home_timeline'], [@post_anxiety1, @post_anxiety2])
      ht_anxiety.remove_items([@post_anxiety1, @post_anxiety2])
      timelines_must_not_include(['groups:anxiety:home_timeline'], [@post_anxiety1, @post_anxiety2])
    end

    it 'should delete all items from related keys' do
      @redis.flushall

      ht_anxiety = RedisCache::HomeTimeline.new(['anxiety'])
      ht_anxiety.add_items([@post_anxiety1, @post_anxiety2])

      dupe_zset(@redis, 'groups:anxiety-ocd:home_timeline', [1, 'groups:anxiety:home_timeline'])
      timelines_must_include(['groups:anxiety-ocd:home_timeline','groups:anxiety:home_timeline'], [@post_anxiety1, @post_anxiety2])
      ht_anxiety.remove_items([@post_anxiety1, @post_anxiety2])
      timelines_must_not_include(['groups:anxiety-ocd:home_timeline','groups:anxiety:home_timeline'], [@post_anxiety1, @post_anxiety2])
    end

  end
end

def to_zset_member_string(item)
  "#{item.class.name.underscore}:#{item.id}"
end

def to_zset_member_strings(items)
  items.map { |item| to_zset_member_string(item) }
end

def dupe_zset(redis, dest_key, src_key)
  redis.zunionstore 'groups:anxiety-ocd:home_timeline', [1, 'groups:anxiety:home_timeline']
end

def timelines_must_include(keys, items)
  keys.each do |key|
    timeline_members = @redis.zrange key, 0, -1
    items.each do |item|
      timeline_members.sort.must_include to_zset_member_string(item)
    end
  end
end

def timelines_must_not_include(keys, items)
  keys.each do |key|
    timeline_members = @redis.zrange key, 0, -1
    items.each do |item|
      timeline_members.sort.wont_include to_zset_member_string(item)
    end
  end
end
