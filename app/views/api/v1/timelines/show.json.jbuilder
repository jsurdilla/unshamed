json.set! :items do
  json.array! @items do |item|
    if item.is_a?(Post)
      json.partial! 'api/v1/posts/show', post: item
    elsif item.is_a?(JournalEntry)
      json.partial! 'api/v1/journal_entries/show', journal_entry: item
    end
  end
end
