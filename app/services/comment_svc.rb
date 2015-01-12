class CommentSvc

  attr :post_ids, :journal_entry_ids

  def initialize(options = {})
    @post_ids = options[:post_ids]
    @journal_entry_ids = options[:journal_entry_ids]
  end

  def comments
    @comments = Comment.includes(:commentable).find_by_sql(sql).tap do
      ActiveRecord::Associations::Preloader.new.preload(@comments, :commentable)
    end
  end

  private

  def sql
    posts_where = nil
    posts_where = Comment
      .arel_table[:commentable_id].in(post_ids)
      .and(Comment.arel_table[:commentable_type].eq('Post')) if post_ids

    journal_entries_where = nil
    journal_entries_where = Comment.
      arel_table[:commentable_id].in(journal_entry_ids).
      and(Comment.arel_table[:commentable_type].eq('JournalEntry')) if journal_entry_ids

    # Wrap each one inside a parenthesis
    items_where = [posts_where, journal_entries_where].compact.map do |conditions|
      Arel::Nodes::Grouping.new(conditions).to_sql
    end.join(' OR ')

    if items_where.blank?
      raise "No posts and journal entries specified."
    end

    <<-SQL
      SELECT c.*, counts.total
      FROM (
        SELECT ROW_NUMBER() OVER (PARTITION BY commentable_id, commentable_type ORDER BY created_at DESC) row_number,
          comments.*
        FROM comments
        WHERE #{items_where}
      ) c
      JOIN (
        SELECT commentable_type, commentable_id, COUNT(*) total
        FROM comments
        WHERE #{items_where}
        GROUP BY commentable_id, commentable_type
      ) counts
        ON counts.commentable_id = c.commentable_id AND counts.commentable_type = c.commentable_type
      WHERE c.row_number < 4
    SQL
  end

end
