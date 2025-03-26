class SplitRandomSetDataJsonToColumns < ActiveRecord::Migration[7.2]
  def change
    add_column :random_sets, :pick_type, :string, default: "mix"
    add_column :random_sets, :rate, :jsonb, default: []
    add_column :random_sets, :pickup_rate, :jsonb, default: []
    add_column :random_sets, :pickup_type, :string, default: "pre"
    add_column :random_sets, :value_list, :jsonb, default: []
  end
end
