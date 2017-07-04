module AuthHelpers
  def user_sign_in(user = nil)
    user ||= create :user
    visit new_user_session_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: 'password'
    click_button 'Log in'
  end

  def admin_sign_in(admin = nil)
    admin ||= create :admin
    visit new_admin_session_path
    fill_in 'Email', with: admin.email
    fill_in 'Password', with: admin.password
    click_button 'Log in'
  end
end
