require 'rails_helper'

feature 'Sharing', :skip do
  let(:customer) { create(:customer, :with_active_subscr) }
  let(:user) { customer.primary_user }
  let(:account) { create(:account, :facebook, :with_facebook_page, :with_facebook_posts, customer: customer) }
  let(:facebook_page) { account.pages.facebook.first }

  let(:post) { facebook_page.posts.last }

  before(:each) { user_sign_in user }

  context 'message textarea', :stub_facebook_campaign do
    specify 'new' do
      visit new_user_share_path(shareable_type: 'posts', shareable_id: post.id)
      expect(page).to have_css '#share_message'
    end

    context 'post now' do
      let(:share) { create(:share, shareable: post, customer: customer, message: 'Awesome post') }
      let(:share2) { create(:share, shareable: post, customer: customer, message: nil) }

      specify 'success' do
        share
        visit edit_user_share_path(shareable_type: 'posts', shareable_id: post.id, id: share.id)
        expect(page).to have_field('share_message', with: 'Awesome post')
      end

      specify 'fail' do
        share2
        visit edit_user_share_path(shareable_type: 'posts', shareable_id: post.id, id: share2.id)
        expect(page).not_to have_css '#share_message'
      end
    end

    context 'scheduled' do
      let(:share) do
        create(:share, :scheduled, shareable: post, customer: customer, message: 'Awesome post')
      end

      let(:share2) do
        create(:share, :expired, shareable: post, customer: customer, message: 'Awesome post')
      end

      specify 'future' do
        share
        visit edit_user_share_path(shareable_type: 'posts', shareable_id: post.id, id: share.id)
        expect(page).to have_field('share_message', with: 'Awesome post')
      end

      specify 'expired' do
        share2
        visit edit_user_share_path(shareable_type: 'posts', shareable_id: post.id, id: share2.id)
        expect(page).to have_field('share_message', with: 'Awesome post')
      end
    end
  end
end
