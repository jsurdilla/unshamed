class CreateJournalEntries < ActiveRecord::Migration
  def change
    create_table :journal_entries do |t|
      t.references :user
      t.string :title
      t.text :body
      t.boolean :public

      t.timestamps

      t.foreign_key :users, column: :user_id
    end
  end
end
