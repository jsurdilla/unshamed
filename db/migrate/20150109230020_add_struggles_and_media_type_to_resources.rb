class AddStrugglesAndMediaTypeToResources < ActiveRecord::Migration
  def change
    change_table :resources do |t|
      t.string :struggles, array: true, default: []
      t.string :media_type
    end
  end
end
