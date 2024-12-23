class Lottery < ApplicationRecord
  has_many :random_sets
  validates :name, presence: :true, length: {minimum:1, maximum:255}
  validates :reality, presence: :true
  validates :origin_id, presence: :true
end
