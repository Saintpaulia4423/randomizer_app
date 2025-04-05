class User < ApplicationRecord
  has_many :random_set, dependent: :nullify
  has_many :user_favorite_random_sets, dependent: :destroy
  has_many :random_set, dependent: :nullify
  validates :user_id, presence: true, length: { minimum: 3, maximum: 255 }
  has_secure_password

  # アカウント関係
  def remember
    session = User.new_token
    update_attribute(:session_digest, User.digest(session))
    session_digest
  end

  def forget
    update_attribute(:session_digest, nil)
  end

  def session_check(session_password)
    return false if session_password.blank?
    BCrypt::Password.new(password_digest).is_password?(session_password)
  end

  # 中間テーブル関係
  def add_favorite(random_set)
    UserFavoriteRandomSet.create!(user_id: self.id, random_set_id: random_set.id)
  end
  def delete_favorite(random_set)
    target = UserFavoriteRandomSet.where("user_id = #{self.id} and random_set_id = #{random_set.id}").first
    return false if target.nil?
    target.destroy!
  end
  # user.favorite_all.eachで各random_set情報取得
  def favorite_all
    User.preload(:user_favorite_random_sets => :random_set).find(self.id).user_favorite_random_sets
  end

  def add_create_random_set(random_set_params)
    self.transaction do
      random_set = RandomSet.create!(random_set_params)
      add_random_set(random_set)
    end
  end
  def add_random_set(random_set)
    UserCreatedRandomSet.create!(user_id: self.id, random_set_id: random_set.id)
  end
  def delete_create(random_set)
    target = UserCreatedRandomSet.where("user_id = #{self.id} and random_set_id = #{random_set.id}").first
    return false if target.nil?
    target.destroy
  end
  def created_all
    User.preload(:user_created_random_sets => :random_set).find(self.id).user_created_random_sets
  end
end
