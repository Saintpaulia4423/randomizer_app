class AddRandomSetsDefaultBoxValueColumn < ActiveRecord::Migration[7.2]
  def change
    add_column :random_sets, :default_value, :integer, :default => -1
  end
end
