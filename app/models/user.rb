class User < ActiveRecord::Base

  include DeviseTokenAuth::Concerns::User

  acts_as_messageable

  has_attached_file :profile_picture,
    :styles => { :medium => "300x300>", :square100 => "100x100", :square50 => "50x50" },
    :default_url => "assets/:style/member@2x.png",
    :storage => :s3,
    :s3_credentials => {
      :access_key_id => Aws.config[:credentials].access_key_id,
      :secret_access_key => Aws.config[:credentials].secret_access_key
    },
    bucket: 'unshamed-prod',
    url:                  ':s3_domain_url',
    path:                 ':class/:attachment/:id/:style/:filename',
    s3_permissions:       :public_read,
    s3_protocol:          'https'
  validates_attachment_content_type :profile_picture, :content_type => /\Aimage\/.*\Z/

  has_many :posts
  has_many :comments
  has_many :friendships
  has_many :friends, through: :friendships
  has_many :friendship_requests
  has_many :incoming_friendship_requests, class_name: 'FriendshipRequest', foreign_key: :receiver_id
  has_many :outgoing_friendship_requests, class_name: 'FriendshipRequest', foreign_key: :user_id
  has_many :journal_entries
  has_one :mhp_profile
  has_one :member_profile

  accepts_nested_attributes_for :member_profile

  scope :onboarded, -> { where(onboarded: true) }

  def full_name
    [first_name, last_name].join(' ')
  end

  def mailboxer_email(object)
    email
  end

  def pending_friend_requests_from(user)
    incoming_friendship_requests.pending.coming_from(user)
  end

  def is_mhp?
    !mhp_profile.nil?
  end

  def is_member?
    !member_profile.nil?
  end

  def struggles
    if is_member?
      member_profile.struggles
    elsif is_mhp?
      mhp_profile.struggles
    else
      []
    end
  end

end
