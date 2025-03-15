class ChangeColumn < ActiveRecord::Migration[7.2]
  def change
    change_column :lotteries, :value, :integer, :default => -1
  end
end
