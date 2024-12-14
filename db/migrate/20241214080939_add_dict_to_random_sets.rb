class AddDictToRandomSets < ActiveRecord::Migration[7.2]
  def change
    add_column :random_sets, :dict, :text
    add_column :random_sets, :edit_pass, :string
  end
end
