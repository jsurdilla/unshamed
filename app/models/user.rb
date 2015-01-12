class User < ActiveRecord::Base

  include DeviseTokenAuth::Concerns::User

  acts_as_messageable

  has_attached_file :profile_picture, :styles => { :medium => "300x300>", :square100 => "100x100", :square50 => "50x50" }, :default_url => "/images/:style/missing.png"
  validates_attachment_content_type :profile_picture, :content_type => /\Aimage\/.*\Z/

  has_many :posts, foreign_key: :author_id
  has_many :friendships
  has_many :friends, through: :friendships
  has_many :journal_entries

  scope :onboarded, -> { where(onboarded: true) }

  def full_name
    [first_name, last_name].join(' ')
  end

  def mailboxer_email(object)
    email
  end

end
