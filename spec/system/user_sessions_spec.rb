require 'rails_helper'

RSpec.describe "UserSessions", type: :system do
  include LoginMacros
  let(:user) { create(:user) }

  describe "ログイン前" do
    context "フォームの入力値が正常" do
      it "ログインが成功する(通常フォーム)" do
        visit user_session_path
        fill_in "Eメール", with: user.email
        fill_in "パスワード", with: user.password
        find('#form_login_button').click
        expect(page).to have_content("ログインしました。")
      end
    end
    context "フォームが未入力" do
      it "ログイン失敗" do
        visit user_session_path
        fill_in "Eメール", with: ""
        fill_in "パスワード", with: ""
        find('#form_login_button').click
        expect(page).to have_content("Eメールまたはパスワードが違います。")
      end
    end
  end
end
