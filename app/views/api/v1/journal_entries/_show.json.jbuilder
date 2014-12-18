json.set! :type, 'JournalEntry'
json.(journal_entry, :id, :title, :body, :public, :created_at, :updated_at)

json.support_count Support.for(journal_entry).count

json.author do
  json.(journal_entry.user, :first_name, :last_name, :full_name)

  json.profile_pictures do
    json.thumb journal_entry.user.profile_picture(:thumb)
  end
end
