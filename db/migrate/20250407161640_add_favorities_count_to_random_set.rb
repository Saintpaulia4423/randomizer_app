class AddFavoritiesCountToRandomSet < ActiveRecord::Migration[7.2]
  def change
    add_column :random_sets, :favorities_count, :integer, default: 0
  end
end
