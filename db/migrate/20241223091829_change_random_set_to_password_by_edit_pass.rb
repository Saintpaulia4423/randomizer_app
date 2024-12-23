class ChangeRandomSetToPasswordByEditPass < ActiveRecord::Migration[7.2]
  def change
    rename_column :random_sets, :edit_pass_digest, :password_digest
  end
end
