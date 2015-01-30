class Post < ActiveRecord::Base
  include RedisCache::GroupItemTracker

  acts_as_commentable

  belongs_to :author, class_name: 'User'
  has_many :supports

  def item_groups
    author.struggles
  end

end
