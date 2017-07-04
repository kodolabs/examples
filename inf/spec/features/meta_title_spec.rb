require 'rails_helper'

describe 'Meta title' do
  let(:customer) { create(:customer, :with_active_subscr) }
  let(:fb_account) { create(:account, :with_facebook_page, customer: customer) }

  before { user_sign_in customer.primary_user }

  context 'success' do
    def page_title(title)
      "#{title} - Influenza AI"
    end

    context 'no accounts' do
      specify 'dashboard' do
        visit user_dashboard_path
        expect(page).to have_content 'You have no connected social media accounts.'
        expect(page).to have_title page_title('Dashboard')
      end

      specify 'social calendar' do
        visit user_articles_path
        expect(page).to have_content 'You have no connected social media accounts.'
        expect(page).to have_title page_title('Scheduled Posts')
      end

      specify 'campaigns' do
        allow_any_instance_of(Customer).to receive(:has_fb_ad_accounts?).and_return(true)
        visit user_campaigns_path
        expect(page).to have_content 'Ad Campaigns'
        expect(page).to have_title page_title('Ad Campaigns')
      end
    end

    context 'with accounts' do
      specify 'menu' do
        fb_account
        visit user_dashboard_path

        links = page.all('.side-menu a, .navbar-right .dropdown-menu a')[0..-2]
        links.each do |link|
          next if link.text.include?('New Post') # TODO: remove when fixing campaign specs
          link.click
          expect(page.title).to include('- Influenza AI')
        end
      end
    end
  end
end
