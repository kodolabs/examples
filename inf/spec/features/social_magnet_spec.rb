require 'rails_helper'

feature 'Social Magnet' do
  let(:customer) { create(:customer, :with_active_subscr) }

  context 'menu' do
    specify 'without added streams' do
      user_sign_in customer.primary_user
      click_on 'Social Magnet'
      expect(current_path).to eq(user_feeds_path)
    end
  end
end
