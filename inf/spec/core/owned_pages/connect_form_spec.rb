require 'rails_helper'

describe OwnedPages::ConnectForm do
  let(:form) { OwnedPages::ConnectForm }

  context 'success' do
    let(:unchecked_page) { { 'id' => 'unchecked_page' } }
    let(:fb_account) { create(:account, :facebook, :with_random_facebook_pages) }
    let(:fb_page) { fb_account.pages.last }
    let(:fb_account2) { create(:account, :facebook, :with_random_facebook_pages) }
    let(:fb_page2) { fb_account2.pages.last }

    def form_params(options)
      { 'pages' => options }
    end

    specify 'checked and unchecked pages' do
      checked_page = { 'id' => 'checked_page', 'checked' => '1' }

      p = form_params(
        '0' => checked_page,
        '1' => unchecked_page
      )

      f = form.from_params(p)
      expect(f.checked_pages).to eq [checked_page]
      expect(f.unchecked_pages).to eq [unchecked_page]
    end

    context 'existing page' do
      specify 'no checked pages' do
        p = form_params(
          '1' => unchecked_page
        )

        f = form.from_params(p)
        expect(f.valid?).to be_truthy
      end

      context 'with handle' do
        specify 'in current account' do
          handle = fb_page.handle
          checked_page = { 'handle' => handle, 'checked' => '1' }
          p = form_params('0' => checked_page)
          f = form.from_params(p, account: fb_account)
          expect(f.valid?).to be_truthy
        end

        specify 'in another accounts' do
          handle = fb_page2.handle
          checked_page = { 'handle' => handle, 'checked' => '1' }
          p = form_params('0' => checked_page)
          f = form.from_params(p, account: fb_account)
          expect(f.valid?).to be_falsey
        end
      end

      context 'with uid' do
        specify 'in current account' do
          uid = fb_page.uid
          checked_page = { 'uid' => uid, 'checked' => '1' }
          p = form_params('0' => checked_page)
          f = form.from_params(p, account: fb_account)
          expect(f.valid?).to be_truthy
        end

        specify 'in another accounts' do
          uid = fb_page2.uid
          checked_page = { 'uid' => uid, 'checked' => '1' }
          p = form_params('0' => checked_page)
          f = form.from_params(p, account: fb_account)
          expect(f.valid?).to be_falsey
        end
      end
    end
  end
end
