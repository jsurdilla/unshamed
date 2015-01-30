class JournalEntry < ActiveRecord::Base
  include RedisCache::GroupItemTracker

  belongs_to :user
  has_many :supports

  validates :title, :body, :user_id, presence: true

  scope :publics, -> { where(public: true) }
  scope :privates, -> { where(public: false) }

  scope :pending, -> { where('published_at IS NULL') }
  scope :published, -> { where('published_at IS NOT NULL') }

  def item_groups
    user.struggles
  end

end
