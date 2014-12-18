class AddProfilePictureToUsers < ActiveRecord::Migration

  def self.up
    remove_column :users, :image
    add_attachment :users, :profile_picture
  end

  def self.down
    add_column :users, :image, :string
    remove_attachment :users, :profile_picture
  end
end
