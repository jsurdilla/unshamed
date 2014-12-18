class Comment < ActiveRecord::Base

  include ActsAsCommentable::Comment

  belongs_to :commentable, :polymorphic => true
  belongs_to :author, foreign_key: :user_id, class_name: 'User'

  default_scope -> { order('created_at ASC') }

  scope :posts, -> { where(commentable_type: 'Post') }

  # TODO: May need to pull this into a service.
  def self.for_post_ids(post_ids)
    Comment.posts.includes(:author).where(commentable_id: post_ids)
  end

end
