require 'rails_helper'

describe Articles::Store do
  let!(:customer) { create(:customer, :with_active_subscr) }
  let!(:facebook_account) { create(:account, :facebook, :with_facebook_page, customer: customer) }
  let!(:facebook_page) { facebook_account.pages.first }
  let!(:facebook_owned_page) { facebook_account.owned_pages.facebook.first }
  let!(:twitter_account) { create(:account, :twitter, :with_twitter_page, customer: customer) }
  let!(:twitter_page) { twitter_account.pages.first }
  let!(:twitter_owned_page) { twitter_account.owned_pages.first }
  let!(:form) { Articles::ArticleForm }
  let!(:command) { Articles::Store }
  let(:article_image) { create(:article_image) }
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

  context 'validation', validation: true do
    it 'ignores invalid data' do
      f = form.from_params(params(content: nil), customer_id: customer.id)
      expect { command.call(f, customer) }.not_to change(Article, :count)
    end

    it 'too many images' do
      ids = [article_image.id] * 5
      f = form.from_params(valid_params.merge(image_ids_str: ids.join(',')), customer_id: customer.id)
      expect { command.call(f, customer) }.not_to change(Article, :count)
    end
  end

  context 'creation' do
    before(:all) { Sidekiq::Testing.disable! }

    context 'facebook' do
      it 'without image' do
        p = params(content: 'facebook without image')
        f = form.from_params(p, customer_id: customer.id)
        expect { command.call(f, customer) }.to change(Article, :count).by(1)
        expect(Article.last.content).to eq 'facebook without image'
      end
    end

    context 'twitter' do
      let!(:targets) do
        {
          '0' => {
            'id' => twitter_owned_page.id,
            'source' => 'twitter'
          }
        }
      end

      it 'without image' do
        p = params(content: 'twitter without image', targets: targets)
        f = form.from_params(p, customer_id: customer.id)
        expect { command.call(f, customer) }.to change(Article, :count).by(1)
        expect(Article.last.content).to eq 'twitter without image'
      end
    end
  end

  context 'updating' do
    before(:all) { Sidekiq::Testing.disable! }
    let!(:article) do
      create(:article, customer: customer, owned_pages: [twitter_owned_page])
    end
    let!(:f) do
      form.from_params(params, id: article.id, customer_id: customer.id)
    end

    it 'works' do
      command.call(f, customer)
      article.reload
      expect(article.content).to eq params[:article][:content]
      expect(article.owned_pages).to eq [facebook_owned_page]
    end
  end

  context 'scheduling' do
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
    let(:article) do
      create(:article,
        customer: customer,
        owned_pages: [twitter_owned_page],
        scheduled_at: time_future1,
        job_id: 'somejobid')
    end
    let!(:time_future1) { Time.zone.parse('19/10/2016 03:47 PM') }
    let!(:time_future2) { Time.zone.parse('19/10/2016 08:00 PM') }

    it 'performs instant posting' do
      p = params(date: '18/10/2016')
      f = form.from_params(p, customer_id: customer.id)
      expect(ShareWorker).to receive(:perform_async)
      command.call(f, customer)
    end

    it 'schedules delayed posting' do
      p = params(date: '19/10/2016')
      f = form.from_params(p, customer_id: customer.id)
      expect(ShareWorker).to(
        receive(:perform_at).with(time_future1, any_args).and_return('somejobid')
      )
      command.call(f, customer)
      expect(Article.last.shares.last.job_id).to eq 'somejobid'
    end

    it 'reschedules delayed posting' do
      p = params(date: '19/10/2016', time: '08:00 PM')
      f = form.from_params(p, id: article.id, customer_id: customer.id)
      command.call(f, customer)
      expect(Article.last.shares.last.scheduled_at).to eq time_future2
    end

    it 'performs instant posting after editing' do
      p = params(date: '18/10/2016')
      f = form.from_params(p, id: article.id, customer_id: customer.id)
      expect(ShareWorker).to receive(:perform_async)
      command.call(f, customer)
      article.reload
      expect(article.shares.last.job_id).to be_nil
      expect(article.shares.last.scheduled_at).to be_nil
    end
  end
end
