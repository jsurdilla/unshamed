class AddOnboardingColsToUsers < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :gender
      t.text :about_me
      t.boolean :onboarded
    end
  end
end
