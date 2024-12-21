class AddRandomSetReferenceToLotteries < ActiveRecord::Migration[7.2]
  def change
    add_reference :lotteries, :random_set, null: false, foreign_key: true
  end
end
