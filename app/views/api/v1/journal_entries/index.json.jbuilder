json.set! :journal_entries do
  json.partial! 'api/v1/journal_entries/show', collection: @journal_entries, as: :journal_entry
end

