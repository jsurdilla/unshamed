class CreateStruggles < ActiveRecord::Migration
  class Struggle < ActiveRecord::Base; end

  def up
    create_table :struggles, id: false do |t|
      t.string :id, null: false, primary_key: true
      t.string :friendly_text

      t.timestamps
    end

    Struggle.create(id: 'anxiety', friendly_text: 'Anxiety')
    Struggle.create(id: 'ocd', friendly_text: 'OCD')
    Struggle.create(id: 'depression', friendly_text: 'Depression')
    Struggle.create(id: 'eatingdisorder', friendly_text: 'Eating Disorder')
    Struggle.create(id: 'addiction', friendly_text: 'Addiction')
  end

  def down
    drop_table :struggles
  end
end
