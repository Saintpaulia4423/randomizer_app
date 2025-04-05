class UserFavoriteRandomSet < ApplicationRecord
  belongs_to :user
  belongs_to :random_set
  validates :user_id, presence: true
  validates :random_set_id, presence: true
end
