class CreateResources < ActiveRecord::Migration
  def change
    create_table :resources do |t|
      t.string :title
      t.string :description
      t.string :url

      t.timestamps
    end
  end
end
