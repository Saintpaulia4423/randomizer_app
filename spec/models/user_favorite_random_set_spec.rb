require 'rails_helper'

RSpec.describe UserFavoriteRandomSet, type: :model do
  let!(:user) { FactoryBot.create(:user) }
  let!(:another_user) { FactoryBot.create(:user) }
  let!(:set) { FactoryBot.create(:random_set) }
  let!(:another_set) { FactoryBot.create(:random_set) }
  describe "validate" do
    it "同じ組み合わせは存在できない" do
      user.add_favorite(set)
      user.add_favorite(another_set)
      another_user.add_favorite(set)
      expect(user.has_favorite?(set)).to eq true
      expect(user.has_favorite?(another_set)).to eq true
      expect(another_user.has_favorite?(set)).to eq true
      result = UserFavoriteRandomSet.build(user_id: user.id, random_set_id: set.id)
      expect(result).to be_invalid
      expect(result.errors[:user_id][0]).to include("既にある組み合わせ")
    end
  end
end
