class FriendshipRequest < ActiveRecord::Base

  include AASM

  belongs_to :user
  belongs_to :receiver, class_name: 'User'

  has_one :friendship

  scope :pending, -> { where(state: 'pending') }

  aasm :column => :state do
    state :pending, initial: true
    state :accepted
    state :rejected

    event :accept, after_commit: :create_friendships! do
      transitions from: :pending, to: :accepted
    end

    event :reject do
      transitions from: :pending, to: :rejected
    end
  end

  # Returns a similar request regardless of which user initiated it.
  def self.reverse_request(user_id, receiver_id)
    FriendshipRequest.pending.where(user_id: receiver_id, receiver_id: user_id).first
  end

  def self.identical_request(user_id, receiver_id)
    FriendshipRequest.pending.where(user_id: user_id, receiver_id: receiver_id).first
  end

  private

  def create_friendships!
    Friendship.connect_friends!(self)
  end

end
