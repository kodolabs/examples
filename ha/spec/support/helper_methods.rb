module HelperMethods
  def user_sign_in(user = nil)
    user ||= create :user
    visit new_user_session_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button I18n.t('devise.buttons.login')
  end

  def admin_sign_in(admin = nil)
    admin ||= create :admin
    visit new_admin_session_path
    fill_in 'Email', with: admin.email
    fill_in 'Password', with: admin.password
    click_button I18n.t('devise.buttons.login')
  end

  def fill_in_registration_form(attributes = {})
    attributes = {
      email: 'jurgen@example.com',
      name: 'Yury',
      password: 'password',
      password_confirmation: 'password'
    }.merge(attributes)

    fill_in 'Email', with: attributes[:email]
    fill_in 'Name', with: attributes[:name]
    fill_in 'Password', with: attributes[:password], match: :first
    fill_in 'Confirm Password', with: attributes[:password_confirmation]

    click_button 'Register'
  end

  def wait_by_true(condition)
    Timeout.timeout(Capybara.default_max_wait_time) do
      sleep(1) if condition
    end
  end
end
