class JournalEntry < ActiveRecord::Base

  belongs_to :user
  has_many :supports

  validates :title, :body, :user_id, presence: true

  scope :pending, -> { where('published_at IS NULL') }
  scope :published, -> { where('published_at IS NOT NULL') }

end
