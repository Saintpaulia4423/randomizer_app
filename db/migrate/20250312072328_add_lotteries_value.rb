class AddLotteriesValue < ActiveRecord::Migration[7.2]
  def change
    add_column :lotteries, :value, :integer, default: 0
  end
end
