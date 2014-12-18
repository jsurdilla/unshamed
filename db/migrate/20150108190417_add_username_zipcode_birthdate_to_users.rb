class AddUsernameZipcodeBirthdateToUsers < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.string :username
      t.string :zip_code
      t.date :birthdate
    end
  end
end
