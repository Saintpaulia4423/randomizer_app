class CreateUserCreatedRandomSets < ActiveRecord::Migration[7.2]
  def change
    create_table :user_created_random_sets do |t|
      t.belongs_to :user, null: false,  foreign_key: { on_delete: :cascade }
      t.belongs_to :random_set, null: false, foreign_key: true
      t.timestamps
    end
  end
end
