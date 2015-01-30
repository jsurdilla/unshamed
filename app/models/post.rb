class Post < ActiveRecord::Base
  include RedisCache::GroupItemTracker

  acts_as_commentable

  belongs_to :author, class_name: 'User'
  has_many :supports, as: :supportable

  def item_groups
    author.struggles
  end

  def commenter_ids
    comments.map(&:user_id)
  end

  def supporter_ids
    supports.map(&:user_id)
  end

end
