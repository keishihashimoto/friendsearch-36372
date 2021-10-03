require 'rails_helper'

RSpec.describe "Users", type: :request do
  before do
    @user1 =FactoryBot.create(:user)
    @user2 =FactoryBot.create(:user)
    @user3 =FactoryBot.create(:user)
    @friend1 = Friend.create(user_id: @user1.id, friend: @user2.id)
    @friend2 = Friend.create(user_id: @user2.id, friend: @user1.id)
    @friend3 = Friend.create(user_id: @user2.id, friend: @user3.id)
  end
  describe "ユーザー詳細の単体テスト" do
    context "友達を登録していないユーザーの場合" do
      it "友達を登録していないユーザーのidを入力した場合、ユーザーidとユーザー名が表示され、friendsの部分には[]と表示される。" do
        get user_path(@user3), as: :json
        expect(response.body).to include(@user3.id.to_s)
        expect(response.body).to include(@user3.name)
        expect(response.body).to include("[]")
      end
    end
    context "友達を1人だけ登録しているユーザーの場合" do
      it "友達を1人だけ登録しているユーザーのidを入力した場合、ユーザーidとユーザー名が表示され、friendsの部分は要素が一つの配列として表示される。" do
        get user_path(@user1), as: :json
        expect(response.body).to include(@user1.id.to_s)
        expect(response.body).to include(@user1.name)
        expect(response.body).to include("[#{@user2.id}]")
      end
    end
    context "友達を複数人登録しているユーザーの場合" do
      it "友達を複数人登録しているユーザーのidを入力した場合、ユーザーidとユーザー名が表示され、friendsの部分には[]の中に友達全員のIDが表示される。" do
        get user_path(@user2), as: :json
        expect(response.body).to include(@user2.id.to_s)
        expect(response.body).to include(@user2.name)
        expect(response.body).to include("[#{@user1.id},#{@user3.id}]")
      end
    end
  end
end
