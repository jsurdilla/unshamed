class CreateSupports < ActiveRecord::Migration
  def change
    create_table :supports do |t|
      t.references :supportable, :polymorphic => true
      t.references :user
      t.string :role, :default => "supports"
      t.timestamps
    end

    add_index :supports, :supportable_type
    add_index :supports, :supportable_id
    add_index :supports, :user_id
  end
end
