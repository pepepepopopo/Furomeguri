require 'rails_helper'

RSpec.describe "Users", type: :system do
  let(:user) { create(:user) }

  describe "ログイン前" do
    describe "ユーザー新規登録" do
      context "フォームの入力値が正常" do
        it "ユーザーの新規作成が成功する" do
          visit new_user_registration_path
          fill_in "Eメール", with: "email@example.com"
          fill_in "パスワード", with: "password"
          fill_in "パスワード（確認用）", with: "password"
          click_button "新規登録"
          expect(page).to have_content "アカウント登録が完了しました。"
        end
      end
    end
  end
end
