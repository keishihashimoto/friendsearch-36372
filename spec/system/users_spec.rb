require 'rails_helper'

RSpec.describe "Users", type: :system do
  before do
    @user1 = FactoryBot.create(:user)
    @user2 = FactoryBot.create(:user)
    @user3 = FactoryBot.create(:user)
    @user4 = FactoryBot.create(:user)
    @user5 = FactoryBot.create(:user)
    @friend1 = Friend.create(user_id: @user1.id, friend: @user2.id)
    @friend2 = Friend.create(user_id: @user2.id, friend: @user1.id)
    @friend3 = Friend.create(user_id: @user2.id, friend: @user3.id)
    @friend4 = Friend.create(user_id: @user4.id, friend: @user3.id)
    @user_friend = FactoryBot.build(:user_friend)
  end

  describe "ユーザー一覧の結合テスト" do
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
  describe "ユーザー新規登録の結合テスト" do
    context "ユーザー新規登録（既存のユーザーが1人も登録されていない時" do
      it "ユーザー名のみの入力で登録できる" do
        # 既存のデータの削除
        User.all.each do |user|
          user.destroy
        end
        Friend.all.each do |friend|
          friend.destroy
        end
        # トップページに遷移する
        visit root_path
        # "新しいユーザーを登録する"ボタンをクリックする
        click_link "新しいユーザーを登録する"
        # ユーザー新規登録ページに遷移する
        expect(current_path).to eq new_user_path
        # "現在選択可能なお友達はいません"と表示されている
        expect(page).to have_content("現在選択可能なお友達はいません")
        # ユーザー名を入力する
        fill_in "user_friend_name", with: @user_friend.name
        # ユーザー情報を登録するボタンを押すとユーザーの数が一つ増える
        expect{
          click_on "ユーザー情報を登録する"
        }.to change{ User.count }.by(1)
        # トップページに遷移する
        expect(current_path).to eq root_path
        # 登録したユーザーのidと名前が表示されている
        expect(page).to have_content(@user_friend.name)
        expect(page).to have_content(@user_friend.user_id)
      end
    end
    context "ユーザー新規登録（既存のユーザーが登録されている時）" do
      it "ユーザー名のみの入力でも登録できる" do
        # トップページに遷移する
        visit root_path
        # "新しいユーザーを登録する"ボタンをクリックする
        click_link "新しいユーザーを登録する"
        # ユーザー新規登録ページに遷移する
        expect(current_path).to eq new_user_path
        # "現在選択可能なお友達はいません"と表示されていない
        expect(page).to have_no_content("現在選択可能なお友達はいません")
        # 既存のユーザーが、友達の候補として表示されており、チェックは入っていない
        User.all.each do |user|
          expect(page).to have_unchecked_field(user.name)
        end
        # ユーザー名を入力する
        fill_in "user_friend_name", with: @user_friend.name
        # ユーザー情報を登録するボタンを押すとユーザーの数が一つ増える
        expect{
          click_on "ユーザー情報を登録する"
        }.to change{ User.count }.by(1)
        # トップページに遷移する
        expect(current_path).to eq root_path
        # 登録したユーザーのidと名前が表示されている
        expect(page).to have_content(@user_friend.name)
        expect(page).to have_content(@user_friend.user_id)
      end
      it "ユーザー名と友達の登録を同時に行うこともできる" do
        # トップページに遷移する
        visit root_path
        # "新しいユーザーを登録する"ボタンをクリックする
        click_link "新しいユーザーを登録する"
        # ユーザー新規登録ページに遷移する
        expect(current_path).to eq new_user_path
        # "現在選択可能なお友達はいません"と表示されていない
        expect(page).to have_no_content("現在選択可能なお友達はいません")
        # 既存のユーザーが、友達の候補として表示されており、チェックは入っていない
        User.all.each do |user|
          expect(page).to have_unchecked_field(user.name)
        end
        # ユーザー名を入力する
        fill_in "user_friend_name", with: @user_friend.name
        # 友達を選択する
        check @user1.name
        # ユーザー情報を登録するボタンを押すとユーザーの数が一つ増える
        # Friendの数も一つ増える
        # @user1から見たfriendの数は増えない
        expect{
          click_on "ユーザー情報を登録する"
        }.to change{ User.count }.by(1).and change{
          Friend.count
        }.by(1).and change{
          Friend.where(user_id: @user1.id).length
        }.by(0)
        # トップページに遷移する
        expect(current_path).to eq root_path
        # 登録したユーザーのidと名前が表示されている
        expect(page).to have_content(@user_friend.name)
        expect(page).to have_content(@user_friend.user_id)
      end
      it "ユーザー名が空欄の場合には登録ができず、元のページに戻される。" do
        # トップページに遷移する
        visit root_path
        # "新しいユーザーを登録する"ボタンをクリックする
        click_link "新しいユーザーを登録する"
        # ユーザー新規登録ページに遷移する
        expect(current_path).to eq new_user_path
        # "現在選択可能なお友達はいません"と表示されていない
        expect(page).to have_no_content("現在選択可能なお友達はいません")
        # 既存のユーザーが、友達の候補として表示されており、チェックは入っていない
        User.all.each do |user|
          expect(page).to have_unchecked_field(user.name)
        end
        # ユーザー名を入力せずに友達を選択する
        check @user1.name
        # ユーザー情報を登録するボタンを押してもユーザーとfriendの数が増えない
        expect{
          click_on "ユーザー情報を登録する"
        }.to change{ User.count }.by(0).and change{
          Friend.count
        }.by(0)
        # ユーザー登録ページに戻される
        expect(page).to have_content("ユーザー情報の登録ページです")
        # エラーメッセージ表示されている
        expect(page).to have_content("Name can't be blank")
        # @user1はチェック済み、他のユーザーはチェックなし
        User.where.not(id: @user1.id).each do |user|
          expect(page).to have_unchecked_field user.name
        end
        expect(page).to have_checked_field @user1.name
      end
    end
  end
  describe "ユーザー詳細の結合テスト" do
    context "友達登録をしていないユーザーについて" do
      it "ユーザーID, ユーザー名, 友達のIDがJSON形式で返される。友達のIDの部分は空の配列になっている。" do
        # トップページに遷移する
        visit root_path
        # @user3の隣の詳細ボタンを押す
        click_link "詳細", href: user_path(@user3)
        # @user3の詳細ページに遷移する
        expect(current_path).to eq(user_path(@user3))
        # ユーザーID, ユーザー名, 友達のIDがJSON形式で返される。友達のIDの部分は空の配列になっている。
        expect(page).to have_content(@user3.id.to_s)
        expect(page).to have_content(@user3.name)
        expect(page).to have_content("[]")
      end
    end
    context "友達登録を1人だけしているユーザーについて" do
      it "ユーザーID, ユーザー名, 友達のIDがJSON形式で返される。友達のIDの部分は要素が一つの配列になっている。" do
        # トップページに遷移する
        visit root_path
        # @user3の隣の詳細ボタンを押す
        click_link "詳細", href: user_path(@user1)
        # @user3の詳細ページに遷移する
        expect(current_path).to eq(user_path(@user1))
        # ユーザーID, ユーザー名, 友達のIDがJSON形式で返される。友達のIDの部分は空の配列になっている。
        expect(page).to have_content(@user1.id.to_s)
        expect(page).to have_content(@user1.name)
        expect(page).to have_content("[#{@user2.id}]")
      end
    end
    context "友達登録をしていないユーザーについて" do
      it "ユーザーID, ユーザー名, 友達のIDがJSON形式で返される。友達のIDの部分は空の配列になっている。" do
        # トップページに遷移する
        visit root_path
        # @user3の隣の詳細ボタンを押す
        click_link "詳細", href: user_path(@user2)
        # @user3の詳細ページに遷移する
        expect(current_path).to eq(user_path(@user2))
        # ユーザーID, ユーザー名, 友達のIDがJSON形式で返される。友達のIDの部分は空の配列になっている。
        expect(page).to have_content(@user2.id.to_s)
        expect(page).to have_content(@user2.name)
        expect(page).to have_content("[#{@user1.id},#{@user3.id}]")
      end
    end
  end
  describe "ユーザー編集の結合テスト" do
    context "ユーザー名を変更する場合" do
      it "ユーザー名を変更すると、ユーザー一覧にも反映されている" do
        # トップページに遷移する
        visit root_path
        # ユーザー名の隣にある"編集"をクリックする
        click_link "編集", href: edit_user_path(@user1)
        # ユーザー編集ページに遷移する
        expect(current_path).to eq(edit_user_path(@user1))
        # ユーザー名が最初から入力されている
        expect(page).to have_field "ユーザー名", with: @user1.name
        # 友達の選択肢の中に、自分自身は表示されていない。
        expect(page).not_to have_field @user1
        # 他のユーザーは全て友達の選択肢として表示されており、現時点で友達登録されているユーザーについてはチェックも入っている
        User.where.not(id: @user1.id).each do |user|
          if Friend.where(user_id: @user1.id, friend: user.id).exists?
            expect(page).to have_checked_field user.name
          else
            expect(page).to have_unchecked_field user.name
          end
        end
        # ユーザー名を変更する
        fill_in "user_friend[name]", with: "名前変更テスト"
        # ユーザー情報を更新するボタンを押してもユーザーとfriendの数は増えない
        expect{
          click_on "ユーザー情報を更新する"
        }.to change{ User.count }.by(0).and change{
          Friend.count
        }.by(0)
        # トップページに遷移する
        expect(current_path).to eq(root_path)
        # 新しいユーザー名が表示されている
        expect(page).to have_content("名前変更テスト")
      end
      it "ユーザー名を空欄にして更新ボタンを押すと情報は更新されず、エラーメッセージが表示される" do
        # トップページに遷移する
        visit root_path
        # ユーザー名の隣にある"編集"をクリックする
        click_link "編集", href: edit_user_path(@user1)
        # ユーザー編集ページに遷移する
        expect(current_path).to eq(edit_user_path(@user1))
        # ユーザー名が最初から入力されている
        expect(page).to have_field "ユーザー名", with: @user1.name
        # 友達の選択肢の中に、自分自身は表示されていない。
        expect(page).not_to have_field @user1
        # 他のユーザーは全て友達の選択肢として表示されており、現時点で友達登録されているユーザーについてはチェックも入っている
        User.where.not(id: @user1.id).each do |user|
          if Friend.where(user_id: @user1.id, friend: user.id).exists?
            expect(page).to have_checked_field user.name
          else
            expect(page).to have_unchecked_field user.name
          end
        end
        # ユーザー名を変更する
        fill_in "user_friend[name]", with: ""
        # ユーザー情報を更新するボタンを押してもユーザーとfriendの数は増えない
        expect{
          click_on "ユーザー情報を更新する"
        }.to change{ User.count }.by(0).and change{
          Friend.count
        }.by(0)
        # ユーザー編集ページに戻される
        expect(page).to have_content("ユーザー情報の更新ページです")
        # エラーメッセージが表示される
        expect(page).to have_content("Name can't be blank")
        # ユーザー名は空欄のままになっている
        expect("#user_friend_name").to have_content("")
      end
    end
    context "友達登録を編集する場合" do
      it "友達登録していないユーザーにチェックを入れて更新ボタンを押すとそのユーザーが友達登録され、チェックを外したユーザーとの友達登録は解除される" do
        # トップページに遷移する
        visit root_path
        # ユーザー名の隣にある"編集"をクリックする
        click_link "編集", href: edit_user_path(@user1)
        # ユーザー編集ページに遷移する
        expect(current_path).to eq(edit_user_path(@user1))
        # ユーザー名が最初から入力されている
        expect(page).to have_field "ユーザー名", with: @user1.name
        # 友達の選択肢の中に、自分自身は表示されていない。
        expect(page).not_to have_field @user1
        # 他のユーザーは全て友達の選択肢として表示されており、現時点で友達登録されているユーザーについてはチェックも入っている
        User.where.not(id: @user1.id).each do |user|
          if Friend.where(user_id: @user1.id, friend: user.id).exists?
            expect(page).to have_checked_field user.name
          else
            expect(page).to have_unchecked_field user.name
          end
        end
        # 友達登録していないユーザー（ここでは@user3）にチェックを入れる
        check @user3.name
        # @user2との友達登録を解除する
        uncheck @user2.name
        # ユーザー情報を更新するボタンを押してもユーザーは増えず、@user2, 3に関する友達登録が増減する
        expect{
          click_on "ユーザー情報を更新する"
        }.to change{ User.count }.by(0).and change{
          Friend.where(user_id: @user1.id, friend: @user3.id).length
        }.by(1).and change{
          Friend.where(user_id: @user1.id, friend: @user2.id).length
        }.by(-1)
        # トップページに遷移する
        expect(current_path).to eq(root_path)
        # @user1から見た@user3は友達として登録されたが、@user3から見た@user1は友達としては登録されていない。
        expect(Friend.exists?(user_id: @user3.id, friend: @user1.id)).to eq(false)
        # @user1から見た@user2は友達登録が解除されたが、@user2から見た@user1は友達として登録されたままである。
        expect(Friend.exists?(user_id: @user2.id, friend: @user1.id)).to eq(true)
      end
      it "友達登録のチェックを変更して更新ボタンを押すと、エラーで戻された場合にそのユーザーがチェック済みで表示される" do
        # トップページに遷移する
        visit root_path
        # ユーザー名の隣にある"編集"をクリックする
        click_link "編集", href: edit_user_path(@user1)
        # ユーザー編集ページに遷移する
        expect(current_path).to eq(edit_user_path(@user1))
        # ユーザー名が最初から入力されている
        expect(page).to have_field "ユーザー名", with: @user1.name
        # 友達の選択肢の中に、自分自身は表示されていない。
        expect(page).not_to have_field @user1
        # 他のユーザーは全て友達の選択肢として表示されており、現時点で友達登録されているユーザーについてはチェックも入っている
        User.where.not(id: @user1.id).each do |user|
          if Friend.where(user_id: @user1.id, friend: user.id).exists?
            expect(page).to have_checked_field user.name
          else
            expect(page).to have_unchecked_field user.name
          end
        end
        # 友達登録していないユーザー（ここでは@user3）にチェックを入れる
        check @user3.name
        # @user2との友達登録を解除する
        uncheck @user2.name
        # ユーザー名を空欄にする
        fill_in "user_friend_name", with: ""
        # ユーザー情報を更新するボタンを押してもユーザーは増えず、@user2, @user3を対象とするfriendの数にも影響がない
        expect{
          click_on "ユーザー情報を更新する"
        }.to change{ User.count }.by(0).and change{
          Friend.where(user_id: @user1.id, friend: @user3.id).length
        }.by(0).and change{
          Friend.where(user_id: @user1.id, friend: @user2.id).length
        }.by(0)
        # ユーザー編集ページに戻される
        expect(page).to have_content("ユーザー情報の更新ページです")
        # エラーメッセージが表示される
        expect(page).to have_content("Name can't be blank")
        # ユーザー名は空欄のままになっている
        expect("#user_friend_name").to have_content("")
        # 既に友達登録済みのユーザーと、先程チェックした@user3はチェック済みになっている
        # チェックを外した@user2はエラーメッセージ表示後もチェックなしの状態になっている
        User.where.not(id: @user1).where.not(id: @user2.id).where.not(id: @user3.id).each do |user|
          if Friend.where(user_id: @user1.id, friend: user.id).exists?
            expect(page).to have_checked_field user.name
          else
            expect(page).to have_unchecked_field user.name
          end
        end
        expect(page).to have_checked_field @user3.name
        expect(page).to have_unchecked_field @user2.name
        # @user3から見た@user1は友達としては登録されていない。
        expect(Friend.exists?(user_id: @user3.id, friend: @user1.id)).to eq(false)
        # @user2から見た@user1は友達として登録されたままである。
        expect(Friend.exists?(user_id: @user2.id, friend: @user1.id)).to eq(true)
      end
    end
    context "既存のユーザーが自分1人だけの時（表示の確認のみ）" do
      it "既存のユーザーが自分1人の時には、「現在選択可能なお友達はいません」と表示される" do
        # 他のユーザーを全て削除
        User.all.each_with_index do |user, i|
          if i >= 1
            user.destroy
          end
        end
        # ユーザー編集ページに遷移
        visit edit_user_path(@user1)
        # 「現在選択可能なお友達はいません」と表示される
        expect(page).to have_content("現在選択可能なお友達はいません")
      end
    end
  end
  describe "ユーザー削除の結合テスト" do
    context "友達登録をしてもされてもいないユーザーの場合" do
      it "友達登録をしていないユーザーの場合はそのユーザーが削除されるだけで終わる" do
        # トップページに遷移する
        visit root_path
        # @user5の隣の削除ボタンを押すとユーザーが1人削除される。friendの数は変わらない。
        expect{
          click_link "削除", href: user_path(@user5)
        }.to change{ User.count }.by(-1).and change{
          Friend.count
        }.by(0)
        # トップページに遷移する
        expect(current_path).to eq root_path
        # @user5の名前とIDが表示されていない
        expect(page).to have_no_content(@user5.name)
        ids = all(".user-id")
        ids.each do |id|
          expect(id).to have_no_content(@user5.id)
        end
      end
    end
    context "友達登録をしているが、相手からは友達登録をされていないユーザーの場合" do
      it "友達登録をしているがされていないユーザーの場合はそのユーザーに加えて、そのユーザーに紐づいているfirendも消える" do
        # トップページに遷移する
        visit root_path
        # @user4の隣の削除ボタンを押すとユーザーが1人削除される。friendの数は変わらない。
        expect{
          click_link "削除", href: user_path(@user4)
        }.to change{ User.count }.by(-1).and change{
          Friend.count
        }.by(-1)
        # トップページに遷移する
        expect(current_path).to eq root_path
        # @user4の名前とIDが表示されていない
        expect(page).to have_no_content(@user4.name)
        ids = all(".user-id")
        ids.each do |id|
          expect(id).to have_no_content(@user4.id)
        end
        # @user4に紐づくFriendインスタンスは全て削除されている
        expect(@user4.friends.length).to eq(0)
      end
    end
    context "友達登録をしていないがされているユーザーの場合" do
      it "友達登録をしていないがされているユーザーの場合はそのユーザーと、そのユーザーをfriendカラムに登録しているFriendインスタンスが全て削除される" do
        # トップページに遷移する
        visit root_path
        # @user3の隣の削除ボタンを押すとユーザーが1人削除される。friendの数は変わらない。
        expect{
          click_link "削除", href: user_path(@user3)
        }.to change{ User.count }.by(-1).and change{
          Friend.count
        }.by(-2)
        # トップページに遷移する
        expect(current_path).to eq root_path
        # @user3の名前とIDが表示されていない
        expect(page).to have_no_content(@user3.name)
        ids = all(".user-id")
        ids.each do |id|
          expect(id).to have_no_content(@user3.id)
        end
        # @user3を友達として登録しているFriendインスタンスは全て削除されている
        expect(Friend.where(friend: @user3.id).length).to eq(0)
      end
    end
    context "友達登録をしてもされてもいるユーザーの場合" do
      it "友達登録をしてもされてもいるユーザーの場合はそのユーザーとそれに紐づくfriend、及びそのユーザーをfriendカラムに登録しているFriendインスタンスが全て削除される" do
        # トップページに遷移する
        visit root_path
        # @user2の隣の削除ボタンを押すとユーザーが1人削除される。friendの数は変わらない。
        expect{
          click_link "削除", href: user_path(@user2)
        }.to change{ User.count }.by(-1).and change{
          Friend.count
        }.by(-3)
        # トップページに遷移する
        expect(current_path).to eq root_path
        # @user3の名前とIDが表示されていない
        expect(page).to have_no_content(@user2.name)
        ids = all(".user-id")
        ids.each do |id|
          expect(id).to have_no_content(@user2.id)
        end
        # @user3を友達として登録しているFriendインスタンスは全て削除されている
        expect(Friend.where(friend: @user2.id).length).to eq(0)
        expect(@user2.friends.length).to eq(0)
      end
    end
  end
end
