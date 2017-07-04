require 'rails_helper'

feature 'Dashboard' do
  let(:customer) { create(:customer, :with_active_subscr) }
  let(:user) { customer.primary_user }
  let(:account) { create(:account, :facebook, :with_facebook_page, :with_facebook_posts, customer: customer) }
  let(:facebook_page) { account.pages.facebook.first }

  let(:post) { facebook_page.posts.last }
  let(:post_2) { create(:post, page: facebook_page, posted_at: 5.hours.ago, content: 'Test content') }

  before { Timecop.freeze Time.zone.local(2016, 10, 20, 18, 0, 0) }
  after { Timecop.return }
  before { user_sign_in user }

  context 'recent posts' do
    context 'success' do
      it 'show recent posts' do
        post
        post_2
        visit user_dashboard_path

        expect(page).to have_content 'Recent Posts'
        expect(page).to have_content 'about 5 hours'
        expect(page).to have_content post.story
        expect(page).to have_content 'Test content'
        expect(page).to have_content post_2.story
      end
    end
  end

  context 'user demographics' do
    let(:facebook_page_2) { account.pages.facebook.last }
    let(:gender_values) do
      {
        'U.55-64' => 3, 'M.55-64' => 257, 'U.35-44' => 26,
        'F.45-54' => 474, 'M.35-44' => 2202, 'M.18-24' => 3962,
        'F.25-34' => 1969, 'U.65+' => 1, 'U.18-24' => 2,
        'M.25-34' => 8490, 'F.65+' => 7, 'F.13-17' => 11,
        'U.45-54' => 16, 'F.55-64' => 203, 'M.65+' => 8,
        'M.13-17' => 28, 'F.35-44' => 988, 'U.25-34' => 27,
        'M.45-54' => 754, 'F.18-24' => 863
      }
    end

    let(:demographic) { create(:demographic, :engaged, page: facebook_page, genders: gender_values) }
    let(:demographic_2) { create(:demographic, :engaged, page: facebook_page_2, genders: gender_values) }

    context 'success' do
      it 'show demographics' do
        demographic
        demographic_2

        visit user_dashboard_path
        within '.percentage-column' do
          expect(page).to have_content('0 %', count: 2)
          percents = [24, 52, 16, 6, 2]
          percents.each { |percent| expect(page).to have_content("#{percent} %") }
        end

        within '.user-demographics' do
          headers = %w(Age Percentage Range)
          headers.each { |header| expect(page).to have_content(header) }
        end

        expect(page).to have_content 'User demographics'
      end
    end
  end

  context 'visitors location' do
    context 'success' do
      let(:countries_values) do
        { 'MN' => 1, 'AU' => 73, 'AE' => 51,
          'IE' => 2, 'UA' => 1, 'US' => 10, 'SA' => 1 }
      end

      let(:history) { create(:history, :days_28, historyable: facebook_page, views: 88) }
      let(:demographic) { create(:demographic, :reached, page: facebook_page, countries: countries_values) }

      it 'show visitor location stats' do
        history
        demographic

        visit user_dashboard_path
        expect(page).to have_content 'Visitors location'
        expect(page).to have_content '88 Views from 7 countries'
        percents = [53, 37, 7, 1, 1]

        percents.each do |percent|
          expect(page).to have_content "#{percent}%"
        end

        countries = ['Australia', 'United Arab Emirates', 'United States', 'Ukraine']
        countries.each do |country|
          expect(page).to have_content country
        end
      end
    end
  end

  context 'page likes' do
    let(:history_1) do
      create(:history, :day, historyable: facebook_page, likes: 12, date: Time.zone.today - 2.days)
    end
    let(:history_2) do
      create(:history, :day, historyable: facebook_page, likes: 21, date: Time.zone.today - 1.day)
    end
    let(:history_3) do
      create(:history, :day, historyable: facebook_page, likes: 21, date: Time.zone.today - 8.days)
    end
    context 'success' do
      it 'show stats' do
        history_1
        history_2
        history_3
        visit user_dashboard_path
        expect(page).to have_content 'Page Likes'
        expect(page).to have_content 'New likes by days'
        within '.page_likes_section' do
          expect(page).to have_content 0, count: 5
          expect(page).to have_content 'Monday 0'
          expect(page).to have_content 'Tuesday 12'
          expect(page).to have_content 'Wednesday 42'
          expect(page).to have_content 'Thursday 0'
          expect(page).to have_content 'Friday 0'
          expect(page).to have_content 'Saturday 0'
          expect(page).to have_content 'Sunday 0'
        end
      end
    end
  end

  context 'header' do
    context 'day period' do
      let(:history) do
        create(:history, :day,
          date: 14.days.ago, connections: 20, males: 20, paid_connections: 20,
          females: 20, engaged_users: 20, likes: 20, historyable: facebook_page)
      end
      let(:history_2) do
        create(:history, :day,
          date: 13.days.ago, connections: 30, males: 30, females: 30, paid_connections: 30,
          engaged_users: 30, likes: 30, historyable: facebook_page)
      end
      let(:history_3) do
        create(:history, :day,
          date: 2.days.ago, connections: 50, males: 50, females: 50, paid_connections: 50,
          engaged_users: 50, likes: 50, historyable: facebook_page)
      end
      let(:history_4) do
        create(:history, :day,
          date: 1.day.ago, connections: 80, males: 80, paid_connections: 80,
          females: 80, likes: 80, engaged_users: 80, historyable: facebook_page)
      end

      context 'page likes' do
        let(:wrappers) do
          %w(
            .page_likes .click_rate .total_males .total_females
            .total_connections .total_paid_connections
          )
        end
        context 'success' do
          specify 'show stats' do
            history
            history_2
            history_3
            history_4

            visit user_dashboard_path
            wrappers.each do |wrapper|
              within wrapper do
                expect(page).to have_content 130
                expect(page).to have_content '160% From last Week'
                expect(page).to have_css '.green'
              end
            end
          end
        end
      end
    end
  end

  context 'social presence' do
    context 'success' do
      it 'show data' do
        account
        visit user_dashboard_path
        expect(page).to have_content 'Your social presence'
      end
    end
  end

  context 'empty layout' do
    let(:error) { 'You have no connected social media accounts' }
    context 'success' do
      let(:empty_fb_account) { create(:account, :facebook, customer: customer) }
      specify 'no any accounts' do
        user
        visit user_dashboard_path

        expect(page).to have_content(error)
      end

      specify 'only facebook account without pages' do
        empty_fb_account
        visit user_dashboard_path

        expect(page).to have_content(error)
      end
    end
    context 'fail' do
      let(:twitter_account) { create(:account, :twitter, :with_twitter_page, customer: customer) }
      specify 'connected twitter account' do
        twitter_account
        visit user_dashboard_path

        expect(page).not_to have_content(error)
      end

      specify 'connected fb page' do
        account
        expect(page).not_to have_content(error)
      end
    end
  end
end
