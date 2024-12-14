class CreateLotteries < ActiveRecord::Migration[7.2]
  def change
    create_table :lotteries do |t|
      t.string :name
      t.text :dict
      t.integer :reality
      t.boolean :defalut_check
      t.integer :origin_id

      t.timestamps
    end
  end
end
