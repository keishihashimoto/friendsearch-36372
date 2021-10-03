require 'rails_helper'

RSpec.describe User, type: :model do
  describe "ユーザー新規登録の単体テスト" do
    before do
      @user1 = FactoryBot.create(:user)
      @user2 = FactoryBot.create(:user)
      @user_friend = FactoryBot.build(:user_friend)
    end
    context "新規登録できる時" do
      it "ユーザー名のみでも新規登録ができる" do
        expect(@user_friend).to be_valid
      end
      it "ユーザー名が既存のユーザーと重複していても登録ができる" do
        @user_friend.name = @user1.name
        expect(@user_friend).to be_valid
      end
      it "ユーザー名に加えて、友達として他のユーザーを1人だけ選択しても保存ができる" do
        @user_friend.friends = [@user1.id]
        expect(@user_friend).to be_valid
      end
      it "ユーザー名に加えて、友達として他のユーザーを複数人選択しても保存ができる" do
        @user_friend.friends = [@user1.id, @user2.id]
        expect(@user_friend).to be_valid
      end
    end
    context "新規登録できないとき" do
      it "ユーザー名と友達が両方ともが空欄だと新規登録できない" do
        @user_friend.name = ""
        @user_friend.valid?
        expect(@user_friend.errors.full_messages).to include("Name can't be blank")
      end
      it "ユーザー名が空欄だと友達を選択していても新規登録ができない" do
        @user_friend.name = ""
        @user_friend.friends = [@user1.id]
        @user_friend.valid?
        expect(@user_friend.errors.full_messages).to include("Name can't be blank")
      end
      it "ユーザー名を入力していても、存在しないユーザーを友達として選択していると新規登録ができない" do
        @user_friend.friends = [(@user1.id.to_i + @user2.id.to_i )]
        @user_friend.valid?
        expect(@user_friend.errors.full_messages).to include("Friends selected doesn't exist.")
      end
    end
  end
end
