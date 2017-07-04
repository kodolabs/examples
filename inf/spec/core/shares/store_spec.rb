require 'rails_helper'

describe Shares::Store do
  let(:customer) { create(:customer, :with_active_subscr) }
  let(:facebook_account) do
    create(:account, :facebook, :with_facebook_page, :with_facebook_posts, customer: customer)
  end
  let(:facebook_page) { facebook_account.pages.first }
  let(:facebook_owned_page) { facebook_account.owned_pages.facebook.first }

  let(:form) { Shares::ShareForm }
  let(:command) { Shares::Store }
  let(:article_image) { create(:article_image) }
  let(:post) { facebook_page.posts.last }
  let(:news) { create(:news) }

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

  context 'creation' do
    before(:all) { Sidekiq::Testing.disable! }

    context 'post' do
      context 'facebook' do
        specify 'success' do
          f = form.from_params(params.except(:share),
            customer: customer,
            shareable: post,
            targets: params[:share][:targets])
          expect { command.call(f, post, customer) }.to change(Share, :count).by(1)
          expect(Share.last.shareable).to eq(post)
        end
      end
    end

    context 'news' do
      specify 'success' do
        f = form.from_params(params.except(:share),
          customer: customer,
          shareable: news,
          targets: params[:share][:targets])
        expect { command.call(f, post, customer) }.to change(Share, :count).by(1)
        expect(Share.last.shareable).to eq(news)
      end
    end
  end

  context 'scheduling', :skip do
    before(:all) do
      Time.zone = 'Kyiv'
      Timecop.freeze(
        Time.zone.local(2016, 10, 18, 15, 47, 0)
      )
      Sidekiq::Testing.disable!
    end
    after(:all) do
      Timecop.return
      Time.zone = 'UTC'
    end
    let(:share) do
      create(
        :share,
        job_id: 'somejobid',
        scheduled_at: time_future1,
        customer: customer,
        owned_pages: [facebook_owned_page],
        shareable: post
      )
    end
    let(:time_future1) { Time.zone.parse('19/10/2016 03:47 PM') }

    it 'schedules delayed posting', :delayed do
      p = params(date: '19/10/2016')
      f = form.from_params(p.except(:share),
        customer: customer,
        post: post,
        targets: params[:share][:targets])
      expect(ShareWorker).to(
        receive(:perform_at).with(time_future1, any_args).and_return('somejobid')
      )
      command.call(f, post, customer)
    end
  end
end
