class AddSessionsToRandomSets < ActiveRecord::Migration[7.2]
  def change
    add_column :random_sets, :session_digest, :string # セッション情報の保存用
    add_column :random_sets, :edit_pass_digest, :string # secure password用の追加
  end
end
