class CreateMhps < ActiveRecord::Migration
  def change
    create_table :mhps do |t|
      t.references :user
      t.string :struggles, default: [], array: true

      t.foreign_key :users, column: :user_id

      t.timestamps
    end
  end
end
