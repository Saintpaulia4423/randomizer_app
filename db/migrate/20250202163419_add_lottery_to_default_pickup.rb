class AddLotteryToDefaultPickup < ActiveRecord::Migration[7.2]
  def change
    add_column :lotteries, :default_pickup, :boolean, default: false # ピックアップ引き用の設定
  end
end
