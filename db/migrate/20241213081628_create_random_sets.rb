class CreateRandomSets < ActiveRecord::Migration[7.2]
  def change
    create_table :random_sets do |t|
      t.string :name
      t.integer :parent
      t.jsonb :data

      t.timestamps
    end
  end
end
