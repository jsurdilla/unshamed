class User < ActiveRecord::Base

  include DeviseTokenAuth::Concerns::User

  acts_as_messageable

  has_attached_file :profile_picture, :styles => { :medium => "300x300>", :square100 => "100x100", :square50 => "50x50" }, :default_url => "/images/:style/missing.png"
  validates_attachment_content_type :profile_picture, :content_type => /\Aimage\/.*\Z/

  has_many :posts, foreign_key: :author_id
  has_many :friendships
  has_many :friends, through: :friendships
  has_many :friendship_requests
  has_many :incoming_friendship_requests, class_name: 'FriendshipRequest', foreign_key: :receiver_id
  has_many :journal_entries

  scope :onboarded, -> { where(onboarded: true) }

  before_save :check_timeline_groups

  def full_name
    [first_name, last_name].join(' ')
  end

  def mailboxer_email(object)
    email
  end

  def pending_friend_requests_from(user)
    incoming_friendship_requests.pending.coming_from(user)
  end

  private

  def check_timeline_groups
    return unless struggles_changed?
    RedisCache::HomeTimeline.new(struggles_was).remove_items(posts + journal_entries)
    RedisCache::HomeTimeline.new(struggles).add_items(posts + journal_entries)
  end

end
