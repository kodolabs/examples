require 'rails_helper'

describe Dashboard::Base do
  let(:user) { create :user }
  let(:customer) { user.customer }
  let(:account) { create(:account, :facebook, :with_facebook_page, customer: customer) }
  let(:twitter_account) { create(:account, :twitter, :with_twitter_page, customer: customer) }

  let(:twitter_page) { twitter_account.pages.twitter.first }
  let(:page) { account.pages.facebook.first }

  let(:account_2) do
    create(:account, :facebook, :with_random_facebook_pages, :with_twitter_page, customer: customer)
  end
  let(:page_2) { account_2.pages.facebook.first }
  let(:page_3) { account_2.pages.facebook.last }
  let(:page_4) { account_2.pages.twitter.last }

  let(:service) { Dashboard::Base.new(customer) }

  context 'recent posts' do
    let(:post) { create(:post, page: page, posted_at: Time.current) }
    let(:post_2) { create(:post, page: page, posted_at: Time.current - 1.day) }
    let(:post_3) { create(:post, page: page, posted_at: Time.current - 2.days) }
    let(:post_4) { create(:post, page: page, posted_at: Time.current - 3.days) }

    let(:user_2) { create(:user) }
    let(:customer_2) { user_2.customer }
    let(:account_2) { create(:account, :facebook, :with_random_facebook_pages, customer: customer_2) }
    let(:page_2) { account_2.pages.facebook.first }

    let(:post_5) { create(:post, page: page_2) }
    let(:post_6) { create(:post) }

    let(:twitter_post) { create(:post, page: twitter_page) }

    context 'success' do
      specify 'fetch only customer 3 recent posts' do
        post
        post_2
        post_3
        post_4
        post_5
        post_6
        twitter_post
        expect(service.recent_posts).to eq [post, post_2, post_3]
      end
    end

    context 'fail' do
      specify 'no posts' do
        account
        expect(service.recent_posts).to be_blank
      end
    end
  end

  context 'user demographics' do
    context 'success' do
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

      let(:gender_values_2) do
        { 'U.35-44' => 10_000 }
      end

      let(:date) { Time.current }

      let(:demographic) { create(:demographic, :engaged, page: page_2, genders: gender_values, date: date) }
      let(:demographic_2) do
        create(:demographic, :engaged, page: page_3, genders: gender_values_2, date: date)
      end
      let(:demographic_3) do
        create(:demographic, :engaged, page: page_3, genders: { 'M.99' => 1 }, date: Time.current - 2.days)
      end

      specify 'valid data' do
        account_2
        demographic

        expect(service.user_demographics_colors.count).to be > 0
        data = service.user_demographics

        expect(data).to eq('13-17' => 0, '18-24' => 24, '25-34' => 52,
                           '35-44' => 16, '45-54' => 6, '55-64' => 2, '65+' => 0)
      end

      specify 'for n pages' do
        demographic
        demographic_2
        demographic_3
        valid_data = {
          '13-17' => 0, '18-24' => 16, '25-34' => 35,
          '35-44' => 44, '45-54' => 4, '55-64' => 2, '65+' => 0
        }
        expect(service.user_demographics).to eq(valid_data)
      end
    end

    context 'fail' do
      specify 'no demographics' do
        account
        expect(service.user_demographics).to be_blank
        expect(service.send(:last_demographic_date)).to be_blank
      end
    end
  end

  context 'visitors location' do
    context 'success' do
      let(:countries_values) do
        { 'MN' => 1, 'AU' => 73, 'AE' => 51, 'IE' => 2, 'UA' => 1, 'US' => 10, 'SA' => 1 }
      end

      let(:countries_values_2) do
        { 'RU' => 1, 'MD' => 1, 'UA' => 3 }
      end

      let(:date) { Time.current }

      let(:history) { create(:history, :days_28, historyable: page_2, views: 88) }
      let(:demographic) do
        create(:demographic, :reached, page: page_2, countries: countries_values, date: date)
      end
      let(:demographic_2) do
        create(:demographic, :reached, page: page_3, countries: countries_values_2, date: date)
      end
      let(:demographic_3) do
        create(:demographic, :reached, page: page_3, countries: { 'TD' => 1 }, date: Time.current - 2.days)
      end

      before(:each) { account_2 }

      specify 'total_views' do
        history
        expect(service.total_views).to eq(88)
      end

      specify 'stats per country' do
        demographic
        valid_data = {
          'Australia' => 53, 'United Arab Emirates' => 37, 'United States of America' => 7,
          'Saudi Arabia' => 1, 'Ukraine' => 1, 'Ireland' => 1, 'Mongolia' => 1
        }
        expect(service.visitors_location).to eq(valid_data)
      end

      specify 'stats per country for n pages' do
        demographic
        demographic_2
        demographic_3

        valid_data = {
          'Australia' => 51, 'United Arab Emirates' => 35, 'United States of America' => 7,
          'Ukraine' => 3, 'Moldova (Republic of)' => 1, 'Russian Federation' => 1,
          'Saudi Arabia' => 1, 'Ireland' => 1, 'Mongolia' => 1
        }

        expect(service.visitors_location).to eq(valid_data)
      end
    end

    context 'fail' do
      specify 'no stats' do
        account
        expect(service.visitors_location).to be_blank
        expect(service.send(:last_history_date)).to be_blank
        expect(service.total_views).to eq(0)
      end
    end
  end

  context 'page likes' do
    context 'new likes by days' do
      before { Timecop.freeze Time.zone.local(2016, 10, 21, 13, 31, 0) }
      after { Timecop.return }

      let(:history_1) do
        create(:history, :day, historyable: page_2, likes: 12, date: Time.zone.today - 2.days)
      end
      let(:history_2) do
        create(:history, :day, historyable: page_2, likes: 21, date: Time.zone.today - 1.day)
      end
      let(:history_3) do
        create(:history, :day, historyable: page_3, likes: 8, date: Time.zone.today - 2.days)
      end
      let(:history_4) do
        create(:history, :day, historyable: page_3, likes: 7, date: Time.zone.today - 3.days)
      end

      let(:empty_data) do
        {
          'Monday' => 0,
          'Tuesday' => 0,
          'Wednesday' => 0,
          'Thursday' => 0,
          'Friday' => 0,
          'Saturday' => 0,
          'Sunday' => 0
        }
      end

      let(:valid_data) do
        {
          'Monday' => 0,
          'Tuesday' => 7,
          'Wednesday' => 20,
          'Thursday' => 21,
          'Friday' => 0,
          'Saturday' => 0,
          'Sunday' => 0
        }
      end

      context 'success' do
        specify 'calculate stats' do
          history_1
          history_2
          history_3
          history_4

          expect(service.new_page_likes).to eq(valid_data)
        end
      end

      context 'fail' do
        specify 'no stats' do
          expect(service.new_page_likes).to eq(empty_data)
        end
      end
    end
  end

  context 'header' do
    context 'day period' do
      context 'clicks, males, females, connections, likes' do
        let(:sections) do
          [
            :click_rate, :total_males, :total_females,
            :total_connections, :total_paid_connections, :page_likes
          ]
        end
        context 'success' do
          before do
            account_2
            create(:history, :day,
              date: 14.days.ago, engaged_users: 20, connections: 20,
              males: 20, females: 20, likes: 20, historyable: page_2, paid_connections: 20)
            create(:history, :day,
              date: 13.days.ago, engaged_users: 30, connections: 30,
              males: 30, females: 30, likes: 30, historyable: page_2, paid_connections: 30)
            create(:history, :day,
              date: 2.days.ago, engaged_users: 50, connections: 50,
              males: 50, females: 50, likes: 50, historyable: page_2, paid_connections: 50)
            create(:history, :day,
              date: 1.day.ago, engaged_users: 80, connections: 80,
              males: 80, females: 80, likes: 80, historyable: page_2, paid_connections: 80)
            create(:history, :day,
              date: 14.days.ago, engaged_users: 4, connections: 4,
              males: 4, females: 4, likes: 4, historyable: page_3, paid_connections: 4)
            create(:history, :day,
              date: 13.days.ago, engaged_users: 5, connections: 5,
              males: 5, females: 5, likes: 5, historyable: page_3, paid_connections: 5)
            create(:history, :day,
              date: 2.days.ago, engaged_users: 10, connections: 10,
              males: 10, females: 10, likes: 10, historyable: page_3, paid_connections: 10)
            create(:history, :day,
              date: 1.day.ago, engaged_users: 12, connections: 12,
              paid_connections: 12, males: 12, females: 12, likes: 12, historyable: page_3)
          end
          specify 'valid stats' do
            sections.each do |section|
              data = service.header[section]
              expect(data[:total_count]).to eq(152)
              expect(data[:percentage]).to eq(158)
            end
          end
        end

        context 'fail' do
          specify 'dont show stats' do
            account
            empty_data = { total_count: 0, percentage: 0 }
            sections.each do |section|
              expect(service.header[section]).to eq(empty_data)
            end
          end
        end
      end
    end
  end

  context 'social presence' do
    context 'page likes by days' do
      before { Timecop.freeze Time.zone.local(2016, 10, 21, 13, 31, 0) }
      after { Timecop.return }

      let(:history_1) do
        create(:history, :day, historyable: page_2, likes: 12, date: Time.zone.today - 2.days)
      end
      let(:history_2) do
        create(:history, :day, historyable: page_2, likes: 21, date: Time.zone.today - 1.day)
      end
      let(:history_3) do
        create(:history, :day, historyable: page_3, likes: 8, date: Time.zone.today - 2.days)
      end
      let(:history_4) do
        create(:history, :day, historyable: page_3, likes: 7, date: Time.zone.today - 3.days)
      end
      let(:history_5) do
        create(:history, :day, historyable: page_4, likes: 7, date: Time.zone.today - 3.days)
      end
      let(:empty_data) do
        {
          labels: 7.downto(1).map { |i| Time.zone.today - i.days },
          values: [0] * 7
        }
      end

      let(:valid_data) do
        {
          labels: 7.downto(1).map { |i| Time.zone.today - i.days },
          values: ([0] * 4) + [14, 20, 21]
        }
      end

      context 'success' do
        specify 'calculate stats' do
          history_1
          history_2
          history_3
          history_4
          history_5

          expect(service.social_presence_data).to eq(valid_data)
        end
      end

      context 'fail' do
        specify 'no stats' do
          expect(service.social_presence_data).to eq(empty_data)
        end
      end
    end
  end
end
