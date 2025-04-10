require 'rails_helper'

RSpec.describe UserCreatedRandomSet, type: :model do
  let!(:user) { FactoryBot.create(:user) }
  let!(:another_user) { FactoryBot.create(:user) }
  let!(:set) { FactoryBot.create(:random_set) }
  describe "validate" do
    it "random_setはユニークであること" do
      UserCreatedRandomSet.create(user_id: user.id, random_set_id: set.id)
      result = UserCreatedRandomSet.build(user_id: another_user.id, random_set_id: set.id)
      expect(result).to be_invalid
      expect(result.errors[:random_set_id][0]).to include("存在します")
    end
  end
end
