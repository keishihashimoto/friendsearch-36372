require 'rails_helper'

RSpec.describe "Users", type: :system do
  before do
    @user1 =FactoryBot.create(:user)
    @user2 =FactoryBot.create(:user)
    @user3 =FactoryBot.create(:user)
    @friend1 = Friend.create(user_id: @user1.id, friend: @user2.id)
    @friend2 = Friend.create(user_id: @user2.id, friend: @user1.id)
    @friend3 = Friend.create(user_id: @user2.id, friend: @user3.id)
  end

  describe "ユーザーモデルの結合テスト" do
    it "ユーザー一覧ページの結合テスト（ユーザーが登録されている場合）" do
      # ユーザー一覧ページに遷移する
      visit root_path
      # "ユーザー一覧です"と表示されている
      expect(page).to have_content("ユーザー一覧です")
      # アプリ名が表示されており、ユーザー一覧へのリンクになっている
      expect(page).to have_link "FriendSearch", href: root_path
      # "新しいユーザーを登録する"ボタンがあり、ユーザー登録画面へのリンクになっている
      expect(page).to have_link "新しいユーザーを登録する", href: new_user_path
      # ユーザー名とユーザーIDが一覧で表示されている（IDが若い順番に上から表示）
      User.all.each_with_index do |user, i|
        expect(
          all("tr")[(i + 1)].all("td")[0]
        ).to have_content(user.id)
        expect(
          all("tr")[(i + 1)].all("td")[1]
        ).to have_content(user.name)
      end
      # ユーザー名の隣には詳細・編集・削除それぞれへのリンクが表示されている
      User.all.each_with_index do |user, i|
        expect(
          all("tr")[(i + 1)].all("td")[1]
        ).to have_link "詳細", href: user_path(user)
        expect(
          all("tr")[(i + 1)].all("td")[1]
        ).to have_link "編集", href: edit_user_path(user)
        expect(
          all("tr")[(i + 1)].all("td")[1]
        ).to have_link "削除", href: user_path(user)
      end
    end
    it "ユーザー一覧ページの結合テスト（ユーザーが登録されていない時）" do
      User.all.each do |user|
        user.destroy
      end
      Friend.all.each do |friend|
        friend.destroy
      end
      # ユーザー一覧ページに遷移する
      visit root_path
      # "ユーザー一覧です"と表示されている
      expect(page).to have_content("ユーザー一覧です")
      # "登録されているユーザーはいません"と表示されている
      expect(page).to have_content("登録されているユーザーはいません")
    end
  end
end
