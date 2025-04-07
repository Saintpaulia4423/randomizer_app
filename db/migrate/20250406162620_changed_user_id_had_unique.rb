class ChangedUserIdHadUnique < ActiveRecord::Migration[7.2]
  def change
    add_index :users, :user_id, unique: true
  end
end
