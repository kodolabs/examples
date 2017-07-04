require 'rails_helper'

describe OwnedPages::Connect::Facebook do
  let(:command) { OwnedPages::Connect::Facebook }
  let(:form) { OwnedPages::ConnectForm }
  let(:customer) { create(:customer) }
  let(:account) { create(:account, :facebook, :with_random_facebook_pages, customer: customer) }

  context 'success' do
    def form_params(options)
      { 'pages' => options }
    end

    specify 'connect checked pages' do
      account
      checked_page = { 'id' => 'checked_page', 'checked' => '1' }
      unchecked_page = { 'id' => 'unchecked_page' }
      p = form_params(
        '0' => checked_page,
        '1' => unchecked_page
      )

      f = form.from_params(p, account: account)
      expect { command.call(f, customer) }.to change(OwnedPage, :count).from(2).to(3)
    end
  end
end
