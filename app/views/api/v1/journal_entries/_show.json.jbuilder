json.set! :type, 'JournalEntry'
json.(journal_entry, :id, :title, :body, :public, :created_at, :updated_at, :posted_at)

json.support_count Support.for(journal_entry).count

json.author do
  json.(journal_entry.user, :id, :username, :first_name, :last_name, :full_name)

  json.profile_pictures do
    json.square50 journal_entry.user.profile_picture(:square50)
  end
end
