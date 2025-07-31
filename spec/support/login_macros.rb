module LoginMacros
  def login_as(user)
    visit user_session_path
    fill_in "Eメール", with: user.email
    fill_in "パスワード", with: user.password
    find('#form_login_button').click
    expect(page).to have_content("ログインしました。")
  end
end
