class AddPrefixToUsers < ActiveRecord::Migration
  def change
    add_column :users, :prefix, :string
  end
end
