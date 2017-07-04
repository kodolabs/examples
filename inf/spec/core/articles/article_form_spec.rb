require 'rails_helper'

describe Articles::ArticleForm do
  let!(:customer) { create(:customer, :with_active_subscr) }
  let!(:facebook_account) { create(:account, :facebook, :with_facebook_page, customer: customer) }
  let!(:facebook_page) { facebook_account.pages.first }
  let!(:facebook_owned_page) { facebook_account.owned_pages.facebook.first }
  let!(:twitter_account) { create(:account, :twitter, :with_twitter_page, customer: customer) }
  let!(:twitter_page) { twitter_account.pages.first }
  let!(:twitter_owned_page) { twitter_account.owned_pages.first }
  let!(:form) { Articles::ArticleForm }

  context 'validation' do
    let!(:valid_params) do
      {
        article: {
          content: 'Content',
          targets: {
            '0' => {
              'id' => facebook_owned_page.id,
              'source' => 'facebook',
              'checked' => 1
            }
          }
        }
      }
    end

    def params(attrs = {})
      valid_params.deep_merge(article: attrs)
    end

    it 'valid with valid params' do
      expect(form.from_params(params, customer_id: customer.id).valid?).to be_truthy
    end

    it 'content presence' do
      f = form.from_params(params(content: nil), customer_id: customer.id)
      expect(f.valid?).to be_falsey
      expect(f.errors.keys.include?(:content))
    end

    context 'targets' do
      it 'invalidates nil' do
        f = form.from_params(params(targets: nil), customer_id: customer.id)
        expect(f.valid?).to be_falsey
        expect(f.errors.keys.include?(:targets))
      end

      it 'validates checks' do
        without_checked_target = valid_params
        without_checked_target[:article][:targets]['0'] = {
          'id' => facebook_owned_page.id,
          'source' => 'facebook'
        }
        f = form.from_params(without_checked_target, customer_id: customer.id)
        expect(f.valid?).to be_falsey
        expect(f.errors.keys.include?(:targets)).to be_truthy
      end
    end

    context 'base form' do
      context 'post now date' do
        specify 'new record' do
          f = form.from_params(params, customer_id: customer.id)
          expect(f.post_now_date?).to be_truthy
          expect(f.schedule_date?).to be_falsey
        end

        specify 'scheduled' do
          future_date = {
            date: (Date.current + 1.day).strftime('%d/%m/%Y'),
            time: Time.current.strftime('%I:%M %p'),
            id: 1
          }

          f = form.from_params(params(future_date), customer_id: customer.id)
          expect(f.post_now_date?).to be_falsey
          expect(f.schedule_date?).to be_truthy
        end
      end

      context 'tab' do
        context 'no errors' do
          specify 'open first tab' do
            f = form.from_params(params, customer_id: customer.id)
            expect(f.tab_class_for(:content)).to include('active')
            expect(f.tab_class_for(:schedule)).to be_falsey
            expect(f.tab_class_for(:target)).to be_falsey
          end
        end

        specify 'content errors' do
          p = params(content: nil)
          f = form.from_params(p, customer_id: customer.id)
          expect(f.tab_class_for(:content)).to include('active')
          expect(f.tab_class_for(:schedule)).to be_falsey
        end

        specify 'target errors' do
          p = params(targets: {
            '0' => {
              'id' => facebook_owned_page.id,
              'source' => 'facebook',
              'checked' => false
            }
          })
          f = form.from_params(p, customer_id: customer.id)
          expect(f.valid?).to be_falsey
          expect(f.tab_class_for(:content)).to be_falsey
          expect(f.tab_class_for(:target)).to include('active')
        end

        specify 'schedule errors' do
          p = params(
            date: (Date.current - 1.day).strftime('%d/%m/%Y'),
            time: Time.current.strftime('%I:%M %p')
          )
          f = form.from_params(p, customer_id: customer.id)
          expect(f.valid?).to be_falsey
          expect(f.tab_class_for(:content)).to be_falsey
          expect(f.tab_class_for(:schedule)).to include('active')
        end
      end

      specify 'content partial' do
        f = form.from_params(params, customer_id: customer.id)
        expect(f.content_partial('article')).to eq 'user/articles/content'
        expect(f.content_partial('news')).to eq 'user/aggregates/news/content'
      end

      specify 'js path' do
        f = form.from_params(params, customer_id: customer.id)
        expect(f.js_path).to eq('articles/form')
      end

      specify 'button text' do
        f = form.from_params(params, customer_id: customer.id)
        expect(f.button_text).to eq 'Post Now'
      end

      specify 'button clicked text' do
        f = form.from_params(params, customer_id: customer.id)
        expect(f.button_clicked_text).to eq 'Posting...'
      end
    end

    context 'selected pages' do
      specify 'new record' do
        f = form.from_params(params, customer_id: customer.id)
        expect(f.chosen_page_ids.sort).to eq [facebook_owned_page.id]
      end

      specify 'persisted record' do
        f = form.from_params(params(targets: {
          '0' => {
            'id' => 0,
            'source' => 'facebook',
            'checked' => 1
          }
        }, customer_id: customer.id, id: -3))

        expect(f.chosen_page_ids.sort).to eq [0].sort
      end

      specify 'persisted and no pages specified' do
        p = params(targets: {
          '0' => {
            'id' => 0,
            'source' => 'facebook',
            'checked' => false
          }
        }, customer_id: customer.id, id: -3)
        f = form.from_params(p)
        allow(f).to receive(:no_pages_selected?).and_return(true)
        expect(f.chosen_page_ids).to eq []
      end
    end

    context 'editable' do
      specify 'new record' do
        f = Articles::ArticleForm.new(customer_id: -1)
        expect(f.editable?).to be_truthy
      end

      context 'persisted' do
        specify 'not expired' do
          future_date = {
            date: (Date.current + 1.day).strftime('%d/%m/%Y'),
            time: Time.current.strftime('%I:%M %p'),
            id: 1
          }

          f = form.from_params(params(future_date), customer_id: customer.id)
          expect(f.editable?).to be_truthy
        end

        specify 'expired' do
          old_date = {
            date: (Date.current - 1.day).strftime('%d/%m/%Y'),
            time: Time.current.strftime('%I:%M %p'),
            id: 1
          }

          f = form.from_params(params(old_date), customer_id: customer.id)
          expect(f.editable?).to be_falsey
        end
      end
    end

    context 'images', images: true do
      context 'initial create' do
        it 'valid image ids' do
          f = form.from_params(valid_params, customer_id: customer.id)
          expect(f.valid?).to be_truthy
          expect(f.image_ids_str).to eq nil
        end
      end

      context 'on validation' do
        it 'valid image ids' do
          f = form.from_params(params(image_ids_str: '1,2,3'), customer_id: customer.id)
          expect(f.image_ids_str).to eq('1,2,3')
        end
      end
    end

    it 'scheduled to future' do
      past_date = {
        date: (Date.current - 1.day).strftime('%d/%m/%Y'),
        time: Time.current.strftime('%I:%M %p')
      }

      f = form.from_params(params(past_date), customer_id: customer.id)
      expect(f.valid?).to be_falsey
      expect(f.errors.keys.include?(:date)).to be_truthy

      future_date = {
        date: (Date.current + 1.day).strftime('%d/%m/%Y'),
        time: Time.current.strftime('%I:%M %p')
      }

      f = form.from_params(params(future_date), customer_id: customer.id)
      expect(f.valid?).to be_truthy
      expect(f.errors.keys.include?(:date)).to be_falsey
    end
  end

  context 'attributes' do
    let!(:article) do
      create(:article, customer: customer, owned_pages: [twitter_owned_page])
    end
    let!(:form) { Articles::ArticleForm.from_model(article) }
    let(:share) { article.shares.last }

    it 'has pages' do
      expect(form.pages).to include(facebook_owned_page)
      expect(form.pages).to include(twitter_owned_page)
    end

    it 'has chosen_page_ids' do
      expect(form.chosen_page_ids).to eq [twitter_owned_page.id]
    end
  end
end
