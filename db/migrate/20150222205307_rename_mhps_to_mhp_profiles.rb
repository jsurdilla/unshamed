class RenameMhpsToMhpProfiles < ActiveRecord::Migration
  def change
    rename_table :mhps, :mhp_profiles
  end
end
