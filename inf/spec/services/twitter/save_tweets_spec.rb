require 'rails_helper'

describe Twitter::SaveTweets do
  context 'success' do
    let(:page) { create(:page) }
    let(:service) { Twitter::SaveTweets }

    context 'touch owned pages' do
      specify 'doesnt touch' do
        allow_any_instance_of(Twitter::SaveTweetsHandle).to receive(:call)
        expect_any_instance_of(Page).not_to receive(:touch_owned_pages)
        service.new(page).call
      end

      specify 'update' do
        allow_any_instance_of(Twitter::SaveTweetsHandle).to receive(:call)
        expect_any_instance_of(Page).to receive(:touch_owned_pages).once
        service.new(page, 'save_history' => true).call
      end
    end

    context 'crawl opengraph data' do
      let(:post) { create(:post, :with_twitter_opengraph, page: page, title: nil) }
      let(:page_1) do
        builder = Nokogiri::HTML::Builder.new do |doc|
          doc.html do
            doc.meta(property: 'twitter:title', content: 'Twitter title')
          end
        end
        builder.to_html
      end

      specify 'success' do
        command = service.new(page)
        stub_request(:get, 'http://esquire.com/news.html')
          .to_return(body: page_1, status: 200)
        data = command.send(:crawl_opengraph, post)
        command.send(:save_opengraph, data, post)
        expect(post.decorate.twitter_opengraph_link).to be_truthy
        expect(post.reload.title).to eq 'Twitter title'
      end
    end
  end
end
