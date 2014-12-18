class Timeline::SingleUserTimeline

  def initialize(requesting_user, target_user)
    @requesting_user = requesting_user
    @target_user = target_user
  end

  def compose(page)
    posts = Post.where(author_id: @target_user.id).order('created_at DESC').page(page).per(20)

    if requesting_for_self?
      journal_entries = JournalEntry.where(['updated_at >= ?', posts.map(&:updated_at).min])
    elsif requesting_for_friend?
      journal_entries = JournalEntry.where(['updated_at >= ?', posts.map(&:updated_at).min]).where(public: true)
    else
      journal_entries = []
    end
    (posts + journal_entries).sort_by(&:updated_at).reverse
  end

  private

  def requesting_for_self?
    @requesting_user == @target_user
  end

  def requesting_for_friend?
    @target_user.friends.include?(@requesting_user)
  end

end
