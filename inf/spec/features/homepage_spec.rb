require 'rails_helper'

describe 'Homepage' do
  before { visit root_path }

  specify 'can go to login page' do
    click_on 'Sign in'
    expect(page).to have_current_path new_user_session_path
  end
end
