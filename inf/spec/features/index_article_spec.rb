require 'rails_helper'

feature 'Index articles' do
  let(:customer) { create(:customer, :with_active_subscr) }
  let(:article_date) { Time.zone.local(2016, 9, 21, 12, 20, 0) }

  before(:each) { user_sign_in(user) }

  skip 'is skipped' do
    context 'success' do
      context 'not scheduled' do
        let(:article_with_image) { create(:article, :with_image, customer: customer, scheduled_at: nil) }
        let(:article) { create(:article, created_at: article_date, customer: customer, scheduled_at: nil) }

        it 'show articles' do
          article_with_image
          article
          visit user_articles_path
          expect(page).to have_content article.content
          expect(page).to have_content 'No image'
          expect(page).to have_css ".article-image[data-src='#{article_with_image.image.url}']"
          expect(page).to have_content '21 Sep'
          expect(page).to have_content 'Posted'

          click_on 'Scheduled posts'
          expect(page).to have_content 'No created posts'
        end
      end

      context 'scheduled' do
        let(:article) { create(:article, customer: customer, scheduled_at: article_date) }

        it 'show articles' do
          article
          visit user_scheduled_articles_path
          expect(page).to have_content article.content
          expect(page).to have_content 'No image'
          expect(page).to have_content '21 Sep'
          expect(page).to have_content 'Scheduled'
        end
      end
    end

    context 'fail' do
      it 'does not show any articles' do
        visit user_articles_path
        expect(page).to have_content 'No created posts'
        click_on 'Scheduled posts'
        expect(page).to have_content 'No created posts'
      end
    end
  end
end
