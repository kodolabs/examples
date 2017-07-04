module AuthHelpers
  def manager_sign_in(manager = nil)
    manager ||= create :manager
    visit new_manager_session_path
    fill_in 'Email', with: manager.email
    fill_in 'Password', with: manager.password
    click_button 'Log in'
  end

  def user_sign_in(user = nil)
    user ||= create :user
    visit new_user_session_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Log in'
  end

  def facilitator_sign_in(facilitator = nil)
    create(:facilitator)
    visit new_facilitator_session_path
    fill_in 'Email', with: facilitator.email
    fill_in 'Password', with: facilitator.password
    click_button 'Log in'
  end
end
