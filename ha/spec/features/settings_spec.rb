require 'rails_helper'

feature 'Settings' do
  let!(:setting) { create :setting }

  before do
    user_sign_in
    visit settings_path
  end

  describe 'list' do
    it 'should show settings' do
      expect(page).to have_content setting.var
    end
  end

  describe 'edit page' do
    before { visit edit_setting_path(setting) }

    it 'can update setting' do
      fill_in 'setting_value', with: 'new value'
      click_button I18n.t('settings.edit.update')
      expect(page).to have_flash I18n.t('settings.setting_updated')
    end
  end
end
