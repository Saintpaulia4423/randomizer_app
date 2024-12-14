class RandomSet < ApplicationRecord
  has_many :lotteries
  validates :name, presence: :true, length: {minimum:3, maximum:255}
end
