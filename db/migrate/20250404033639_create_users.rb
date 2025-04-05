class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.string :user_id
      t.string :password_digest
      t.string :session_digest

      t.timestamps
    end
  end
end
