class UserCreatedRandomSet < ApplicationRecord
  belongs_to :user
  belongs_to :random_set
  validates :user_id, presence: true
  validates :random_set_id, presence: true, uniqueness: true
end
