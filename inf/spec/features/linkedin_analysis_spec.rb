require 'rails_helper'

feature 'LinkedIn Analysis' do
  let!(:customer) { create(:customer, :with_active_subscr) }
  before(:each) do
    user_sign_in(customer.primary_user)
  end

  context 'error' do
    context 'with account' do
      let!(:linkedin_account) { create(:account, :linkedin, :with_linkedin_page, customer: customer) }
      it 'invalid page id' do
        allow_any_instance_of(Linkedin::Service).to receive(:get).and_raise(Linkedin::WrongPageException)
        visit user_linked_in_analytics_path(page_id: 123)
        expect(page).to have_flash I18n.t('linked_in.no_page_error')
      end

      it 'no connection to linkedin' do
        allow_any_instance_of(Linkedin::Service).to receive(:get)
          .and_raise(Linkedin::ConnectionRefusedException)
        visit user_linked_in_analytics_path
        expect(page).to have_flash I18n.t('linked_in.network_error')
      end
    end

    it 'not authenticated to linked in' do
      visit user_linked_in_analytics_path
      expect(page).to have_content('You have no connected LinkedIn account')
    end
  end
end
