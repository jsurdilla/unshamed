# Preview all emails at http://localhost:3000/rails/mailers/feed_item_mailer
class FeedItemMailerPreview < ActionMailer::Preview
  def new_comment_post_preview
    FeedItemMailer.new_comment(User.first, Post.last)
  end

  def new_comment_journal_entry_preview
    FeedItemMailer.new_comment(User.first, JournalEntry.last)
  end
end
