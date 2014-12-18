class MoveStrugglesToMemberProfiles < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.remove :struggles
    end

    create_table :member_profiles do |t|
      t.references :user
      t.string :struggles, default: [], array: true

      t.foreign_key :users, column: :user_id

      t.timestamps
    end
  end
end
