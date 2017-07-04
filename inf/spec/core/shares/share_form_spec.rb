require 'rails_helper'

describe Shares::ShareForm do
  let(:customer) { create(:customer, :with_active_subscr) }
  let(:facebook_account) do
    create(:account, :facebook, :with_random_facebook_pages, :with_facebook_posts, customer: customer)
  end
  let(:facebook_page) { facebook_account.pages.last }
  let(:facebook_owned_page) { facebook_account.owned_pages.facebook.first }
  let(:form) { Shares::ShareForm }
  let(:post) { facebook_page.posts.last }
  let(:news) { create(:news) }

  context 'validation' do
    let(:valid_params) do
      {
        share: {
          targets: {
            '0' => {
              'id' => facebook_owned_page.id,
              'checked' => 1
            }
          }
        }
      }
    end

    def params(attrs = {})
      valid_params.deep_merge(share: attrs)
    end

    it 'valid with valid params' do
      expect(form.from_params(params.except(:share),
        customer: customer,
        post: post,
        targets: valid_params[:share][:targets]).valid?).to be_truthy
    end
  end

  context 'attributes' do
    let(:share) do
      create(:share, :scheduled,
        customer: customer,
        owned_pages: [facebook_owned_page],
        shareable: post)
    end
    let(:form) { Shares::ShareForm.from_model(share) }

    it 'has date' do
      expect(form.date).to eq form.scheduled_at.strftime('%d/%m/%Y')
      form.date = '01/01/2020'
      expect(form.date).to eq '01/01/2020'
    end

    it 'has time' do
      expect(form.time).to eq form.scheduled_at.strftime('%I:%M %p')
      form.time = '00:30 AM'
      expect(form.time).to eq '00:30 AM'
    end

    it 'has pages', :pages do
      expect(form.pages).to be_truthy
    end

    it 'has chosen_page_ids' do
      expect(form.chosen_page_ids).to eq [facebook_owned_page.id]
    end
  end

  context 'news' do
    let(:share) { create(:share, shareable: news, customer: customer) }
    let(:form) { Shares::ShareForm.from_model(share) }

    specify 'shareable_type' do
      expect(form.shareable_type).to eq 'News'
    end

    specify 'form_class' do
      expect(form.form_class).to eq 'share-news'
    end

    specify 'new_modal_attributes' do
      attrs = { shareable: news, customer: customer }
      expect(form.new_modal_attributes).to eq(attrs)
    end
  end

  context 'post' do
    let(:share) { create(:share, shareable: post, customer: customer) }
    let(:form) { Shares::ShareForm.from_model(share) }

    specify 'shareable_type' do
      expect(form.shareable_type).to eq 'Post'
    end

    specify 'form_class' do
      expect(form.form_class).to eq 'share-post'
    end

    specify 'new_modal_attributes' do
      attrs = { shareable: post, customer: customer }
      expect(form.new_modal_attributes).to eq(attrs)
    end
  end

  context 'button text' do
    let(:share) { create(:share, shareable: post, customer: customer, scheduled_at: nil) }
    let(:share_2) { create(:share, :scheduled, shareable: post, customer: customer) }

    specify 'scheduled share' do
      form = Shares::ShareForm.from_model(share_2)
      expect(form.share_button_text).to eq 'Schedule Share'
    end

    specify 'new share' do
      form = Shares::ShareForm.from_model(share)
      expect(form.share_button_text).to eq 'Share Now'
    end
  end
end
