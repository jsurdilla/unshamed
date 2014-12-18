json.journal_entry do
  json.partial! 'api/v1/journal_entries/show', journal_entry: @journal_entry
end

