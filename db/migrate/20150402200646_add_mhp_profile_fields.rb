class AddMhpProfileFields < ActiveRecord::Migration
  def change
    change_table :mhp_profiles do |t|
      t.string :email
      t.text :qualification
      t.text :education
      t.text :about_me
    end
  end
end
