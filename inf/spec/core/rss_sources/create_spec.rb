require 'rails_helper'

describe RssSources::Create do
  let(:service) { RssSources::Create }

  context 'when unpublished' do
    def params(custom = {})
      custom.reverse_merge(
        title: 'Some title',
        url: 'https://www.google.com/',
        kind: :research
      )
    end

    context 'invalid when' do
      it 'title empty' do
        form = RssSources::RssSourceForm.from_params(params(title: ''))
        service.call(form)
        expect(RssSource.count).to eq 0
        expect(form.valid?).to be_falsey
      end

      it 'url empty' do
        form = RssSources::RssSourceForm.from_params(params(url: ''))
        service.call(form)
        expect(RssSource.count).to eq 0
        expect(form.valid?).to be_falsey
      end
    end

    context 'when title, kind and url are present' do
      it 'is valid' do
        expect(SyncRssSourceWorker).to receive(:perform_async)
        form = RssSources::RssSourceForm.from_params(params)
        service.call(form)
        expect(form.valid?).to be_truthy

        expect(RssSource.count).to eq 1

        rss_source = RssSource.last
        expect(rss_source.topics.count).to eq 0
        expect(rss_source.add_automatically).to be_falsey
        expect(rss_source.title).to eq params[:title]
        expect(rss_source.url).to eq params[:url]
        expect(rss_source.kind).to eq 'research'
      end

      it 'save with topics' do
        topic = create :topic
        expect(SyncRssSourceWorker).to receive(:perform_async)
        form = RssSources::RssSourceForm.from_params(
          params(add_automatically: true, topic_ids: [topic.id])
        )
        service.call(form)
        expect(form.valid?).to be_truthy

        expect(RssSource.count).to eq 1

        rss_source = RssSource.last
        expect(rss_source.topics.count).to eq 1
        expect(rss_source.add_automatically).to be_truthy
        expect(rss_source.title).to eq params[:title]
        expect(rss_source.url).to eq params[:url]
        expect(rss_source.kind).to eq 'research'
      end
    end
  end
end
