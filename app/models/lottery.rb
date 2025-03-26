class Lottery < ApplicationRecord
  has_many :random_sets
  validates :name, presence: :true, length: { minimum: 1, maximum: 255 }
  validates :reality, presence: :true
  validates :origin_id, presence: :true
  validates :value, comparison: { greater_than_or_equal_to: -1 }

  # 検索設定
  def
    self.ransackable_attributes(auth_object = nil) [ "name", "id", "reality", "created_at", "updated_at", "default_check", "default_pickup", "dict" ]
  end
end
