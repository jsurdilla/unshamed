class Comment < ActiveRecord::Base

  include ActsAsCommentable::Comment

  belongs_to :commentable, :polymorphic => true
  belongs_to :author, foreign_key: :user_id, class_name: 'User'

  default_scope -> { order('created_at ASC') }

  scope :posts, -> { where(commentable_type: 'Post') }
  scope :journal_entries, -> { where(commentable_type: 'JournalEntry') }

  # TODO: May need to pull this into a service.
  def self.for_post_ids(post_ids)
    Comment.posts.includes(:author).where(commentable_id: post_ids)
  end

  def self.for_journal_entry_ids(journal_entry_ids)
    Comment.journal_entries.includes(:author).where(commentable_id: journal_entry_ids)
  end

end
