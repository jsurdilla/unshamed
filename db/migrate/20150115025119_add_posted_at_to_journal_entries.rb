class AddPostedAtToJournalEntries < ActiveRecord::Migration
  def change
    add_column :journal_entries, :posted_at, :datetime
  end
end
