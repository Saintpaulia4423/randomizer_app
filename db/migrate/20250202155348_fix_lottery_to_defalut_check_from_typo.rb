class FixLotteryToDefalutCheckFromTypo < ActiveRecord::Migration[7.2]
  def change
    rename_column :lotteries, :defalut_check, :default_check
  end
end
