class RenameImperfectionsToStruggles < ActiveRecord::Migration
  def change
    rename_column :users, :imperfections, :struggles
  end
end
