class JournalEntry < ActiveRecord::Base
  acts_as_commentable

  belongs_to :user
  has_many :supports, as: :supportable

  validates :title, :body, :user_id, presence: true

  scope :publics, -> { where(public: true) }
  scope :privates, -> { where(public: false) }

  scope :pending, -> { where('published_at IS NULL') }
  scope :published, -> { where('published_at IS NOT NULL') }

  def item_groups
    user.struggles
  end

  def commenter_ids
    comments.map(&:user_id)
  end

  def supporter_ids
    supports.map(&:user_id)
  end

end
