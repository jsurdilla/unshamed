class AddImperfectionsColumnToUsers < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.string :imperfections, array: true, default: []
    end
  end
end
