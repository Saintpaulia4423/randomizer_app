class ChangeLotteriesToDefalutCheck < ActiveRecord::Migration[7.2]
  def change
    change_column :lotteries, :defalut_check, :boolean, :default => false
  end
end
