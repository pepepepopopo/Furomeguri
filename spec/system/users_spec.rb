require 'rails_helper'

RSpec.describe "Users", type: :system do
  include LoginMacros
  let(:user) { create(:user) }

  describe "ログイン前" do
    describe "ユーザー新規登録" do
      context "フォームの入力値が正常" do
        it "ユーザーの新規作成が成功する" do
          visit new_user_registration_path
          fill_in "Eメール", with: "email@example.com"
          fill_in "パスワード", with: "password"
          fill_in "パスワード（確認用）", with: "password"
          find('#form_signin_button').click
          expect(page).to have_content "アカウント登録が完了しました。"
        end
      end
      context "フォーム入力値が異常なため登録失敗" do
        it "メールアドレスが未入力" do
          visit new_user_registration_path
          fill_in "Eメール", with: ""
          fill_in "パスワード", with: "password"
          fill_in "パスワード（確認用）", with: "password"
          find('#form_signin_button').click
          expect(page).to have_content "Eメールを入力してください"
        end
        it "使用済みのメールアドレスを使用" do
          existed_user = create(:user)
          visit new_user_registration_path
          fill_in "Eメール", with: existed_user.email
          fill_in "パスワード", with: "password"
          fill_in "パスワード（確認用）", with: "password"
          find('#form_signin_button').click
          expect(page).to have_content "Eメールはすでに存在します"
        end
      end
    end
    context "ヘッダーの表示がログイン前" do
      it "旅行計画作成ボタンが表示されない" do
        visit root_path
        expect(page).not_to have_button("旅程作成")
      end
    end
  end
  describe "ログイン後" do
    before { login_as(user) }
    context "ヘッダー表示がログイン後" do
      it "旅程作成!ボタンが表示される" do
        visit root_path
        expect(page).to have_link("旅程作成!")
      end
    end
    context "新規旅行計画を作成" do
      it "新規作成した旅行計画が作成される" do
        visit new_itinerary_path
        fill_in "タイトル", with: "タイトル"
        fill_in "サブタイトル", with: "サブタイトル"
        click_button "Let's 旅行作り!"
        expect(page).to have_content "新規旅行計画を作成しました"
      end
    end
  end
end
