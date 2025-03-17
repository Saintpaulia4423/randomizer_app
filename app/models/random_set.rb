class RandomSet < ApplicationRecord
  has_many :lotteries
  validates :name, presence: :true, length: {minimum:3, maximum:255}
  validates :password, presence: :ture
  validates :pick_type, inclusion: { in: %w[mix box], message: "%{value} is not a valid status" }
  validates :pickup_type, inclusion: { in: %w[pre percent-ave percent-fix], message: "%[value] is not a valid status" }
  validate :rate_pickup_rate_with_array_into_fixed_hash
  before_save :list_sort_by_reality


  has_secure_password

  # 検索設定
  def
    self.ransackable_attributes(auth_object = nil) ["name", "id", "created_at", "updated_at"]
  end

  # セッション情報の記録
  def remember
    session = RandomSet.new_token
    update_attribute(:session_digest, RandomSet.digest(session))
    session_digest
  end

  # セッション情報の破棄
  def forget
    update_attribute(:session_digest, nil)
  end

  # セッション情報の照合
  def session_check(session_password)
    return false if session_password.blank?
    BCrypt::Password.new(password_digest).is_password?(session_password)
  end

  class << self

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
  private
    def rate_pickup_rate_with_array_into_fixed_hash
      # rate,pickup_rateはArrayであること。
      unless rate.is_a?(Array) || pickup_rate.is_a?(Array) || value_list.is_a?(Array)
        return
      end

      rate.each_with_index do |item, index|
        check_into_fixed_hash(:rate, item, index)
      end

      pickup_rate.each_with_index do |item, index|
        check_into_fixed_hash(:pickup_rate, item, index)
      end

      value_list.each_with_index do |item, index|
        check_into_fixed_hash(:value_list, item, index)
      end
    end
    # 判定
    def check_into_fixed_hash(symbol, item, index)
      # そもそも何も入っていなければなし
      if item == []
        return
      end
      unless item.is_a?(Hash) && item.key?("reality") && item.key?("value")
        errors.add(symbol, "Itme index #{index} is invalid: Must include keys reality and value")
        return
      end

      unless item["reality"].is_a?(Numeric) && item["value"].is_a?(Numeric)
        errors.add(symbol, "Item index #{index} is invalid: Only values")
        return
      end
    end
    # 配列の並びをレアリティ基準でソートする。
    def list_sort_by_reality
      unless rate.blank?
        self.rate = rate.sort_by{ |target_data| target_data["reality"] }
      end
      unless pickup_rate.blank?
        self.pickup_rate = pickup_rate.sort_by{ |target_data| target_data["reality"] }
      end
      unless value_list.blank?
        self.value_list = value_list.sort_by{ |target_data| target_data["reality"] }
      end
    end
end
