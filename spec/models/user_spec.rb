require 'rails_helper'

RSpec.describe User, type: :model do
  let!(:set) { FactoryBot.create(:random_set) }
  let!(:add_set) { FactoryBot.create(:random_set) }
  let!(:user) { FactoryBot.create(:user) }
  describe "メソッド確認" do
    describe "validation関係" do
      it "重複user_idは拒否する" do
        result = User.build(user_id: user.user_id, password: user.password)
        expect(result).to be_invalid
        expect(result.errors[:user_id][0]).to include("存在します")
      end
      it "passwordがなければ作成できない" do
        result = User.build(user_id: "test_case", password: "")
        expect(result).to be_invalid
        expect(result.errors[:password][0]).to include("を入力してください")
      end
    end
    describe "セッション関係" do
      it "remember" do
        result = user.remember
        expect(user.session_digest).to eq result
      end
      it "forget" do
        result = user.remember
        expect(user.session_digest).to eq result
        user.forget
        expect(user.session_digest).to_not eq result
      end
      it "session_check" do
        expect(user.session_check(user.password)).to eq true
      end
    end
    describe "中間テーブル関係" do
      context "favorite" do
        it "add_favorite" do
          result = UserFavoriteRandomSet.where(user_id: user.id, random_set_id: set.id)
          expect(result).to eq []
          user.add_favorite(set)
          result = UserFavoriteRandomSet.where(user_id: user.id, random_set_id: set.id)
          expect(result).to_not eq []
        end
        it "has_favorite?" do
          expect(user.has_favorite?(set)).to eq false
          user.add_favorite(set)
          expect(user.has_favorite?(set)).to eq true
        end
        it "delete_favorite" do
          user.add_favorite(set)
          expect(user.has_favorite?(set)).to eq true
          user.delete_favorite(set)
          expect(user.has_favorite?(set)).to eq false
        end
        it "flip_favorite" do
          expect(user.has_favorite?(set)).to eq false
          user.flip_favorite(set)
          expect(user.has_favorite?(set)).to eq true
          user.flip_favorite(set)
          expect(user.has_favorite?(set)).to eq false
        end
        it "favorite_all" do
          user.add_favorite(set)
          user.add_favorite(add_set)
          result = user.favorite_all
          expect(result[0].random_set.id).to eq set.id
          expect(result[1].random_set.id).to eq add_set.id
        end
      end
      context "created" do
        it "add_random_set" do
          user.add_random_set(set)
          result = UserCreatedRandomSet.where(user_id: user.id, random_set_id: set.id).present?
          expect(result).to eq true
        end
        it "add_create_random_set" do
          add = { name: "Add_Set", password: "add" }
          user.add_create_random_set(add)
          random_set = RandomSet.find_by(name: add[:name])
          result = UserCreatedRandomSet.where(user_id: user.id, random_set_id: random_set.id).present?
          expect(result).to eq true
        end
        it "delete_create" do
          user.add_random_set(set)
          result = UserCreatedRandomSet.where(user_id: user.id, random_set_id: set.id).present?
          expect(result).to eq true
          user.delete_create(set)
          result = UserCreatedRandomSet.where(user_id: user.id, random_set_id: set.id).present?
          expect(result).to eq false
        end
        it "created_all" do
          user.add_random_set(set)
          result = user.created_all
          expect(result[0].random_set).to eq set 
        end
      end
    end
  end
  describe "削除時の挙動" do
    before do
      user.add_favorite(set)
      user.add_random_set(set)
      user.destroy
    end
    it "削除時にfavoriteは消える" do
      result = UserFavoriteRandomSet.all.present?
      expect(result).to eq false
    end
    it "削除してもsetは残るが、setの作成者情報が消える" do
      result = UserCreatedRandomSet.all.present?
      expect(result).to eq false
      expect(set.destroyed?).to eq false
      expect(set.created_by).to eq nil
    end
  end
end
