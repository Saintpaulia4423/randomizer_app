class RandomSet < ApplicationRecord
  has_many :lotteries
  validates :name, presence: :true, length: {minimum:3, maximum:255}
  validates :password, presence: :ture

  has_secure_password

  # 検索設定
  def
    self.ransackable_attributes(auth_object = nil) ["name", "id", "created_at", "updated_at"]
  end

  # セッション情報の記録
  def remember(digest)
    self.session = RandomSet.new_token
    update_attribute(:session_digest, RandomSet.digest(session))
    remember_digest
  end

  # セッション情報の破棄
  def forget
    update_attribute(:session, nil)
  end

  # セッション情報の照合
  def session_check(session_password)
    return false if session_password.blank?
    BCrypt::Password.new(session_digest).is_password?(session_password)
  end

  class << self

    private
      # 新たなトークンを与える
      def new_token
        SecureRandom.urlsafe_base64
      end

      # ハッシュを与える。
      def digest(string)
        cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
        BCrypt::Password.create(string, cost: cost)
      end
  end 
end
