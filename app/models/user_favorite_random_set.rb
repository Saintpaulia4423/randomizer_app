class UserFavoriteRandomSet < ApplicationRecord
  belongs_to :user
  belongs_to :random_set, counter_cache: :favorities_count
  validates :user_id, presence: true, uniqueness: { scope: :random_set_id }
  validates :random_set_id, presence: true
end
