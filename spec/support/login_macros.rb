module LoginMacros
  def login(user)
    visit user_session_path
    fill_in "Eメール", with: user.email
    fill_in "パスワード", with: user.password
    click_on "ログイン"
  end
end
