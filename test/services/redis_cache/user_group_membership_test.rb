require 'test_helper'

class RedisCache::UserGroupMembershipTest < ActiveSupport::TestCase
  describe '.add_items to a single-group membership where key is uninitialized' do
    it 'should initialize the key in the `struggles:struggle_name:members` format'
    it 'should initialize the key with all members facing the struggle'
    it 'should include the new item(s)'
  end

  describe '.add_items to a single-group membership where key is already initialized' do
    it 'should include the new item(s)'
  end

  describe '.add_items to a multi-group membership where key is uninitialized' do
    it 'should initialize the aggregate key in the format `struggles:dash_sep_sorted_struggle_names:members`'
    it 'should initialize the aggregate key with all members facing any of the struggles'
    it 'should include the new item(s)'
    it 'should initialize the constituent key if it does not exist'
    it 'should add it to the constituent key it if does exist'
  end

  describe '.add_items to a multi-group membership where key is already initialized' do
    it 'should include the new item(s)'
    it 'should initialize the constituent key if it does not exist'
    it 'should add it to the constituent key it if does exist'
  end

  describe '.remove_items from a single-group membership' do
    it 'should remove it'
  end

  describe '.remove_items from a multi-group membership' do
    it 'should remove it from the aggregate key'
    it 'should remove it from each of the constituent key'
  end
end
