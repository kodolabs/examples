require 'rails_helper'

describe Articles::FetchImages do
  let!(:domain) { create :domain, index_status: 'indexed' }
  let!(:blog) { create :blog }
  let!(:host) { create :host, blog: blog, domain: domain, active: true }

  describe 'Save article' do
    context 'mode - default' do
      it 'one image' do
        article = create :article, blog: blog, body: <<-HTML
          Some text
          <img src="test.png" style="width: 200px">
        HTML
        allow_any_instance_of(ArticleImageUploader).to receive(:filename).and_return('test.png')
        allow_any_instance_of(ArticleImageUploader).to receive(:url).and_return(
          '/image/test.png'
        )
        main_image = ArticleImage.create(article_id: article.id, width: 200)
        ArticleImages::Import.any_instance.stub(:main_image).and_return(main_image)
        allow_any_instance_of(ArticleImages::Import).to receive(:create_main_image).and_return(main_image)
        allow_any_instance_of(Kernel).to receive(:open).and_return('input.jpg')
        allow_any_instance_of(ArticleImages::Import).to receive(:processing_image).and_return(
          'input.jpg'
        )

        Articles::FetchImages.call(article: article, blog: blog)

        expect(ArticleImage.count).to eq(4)
        expect(article.reload.body.index('/image/test.png')).to be_truthy
        expect(article.reload.body.index('/image/test.png 900w')).to be_truthy
      end
    end

    context 'mode - import' do
      it 'one image' do
        article = create :article, blog: blog, body: <<-HTML
          Some text
          <img src="test.png" style="width: 200px">
        HTML
        allow_any_instance_of(ArticleImageUploader).to receive(:filename).and_return('test.png')
        allow_any_instance_of(ArticleImageUploader).to receive(:url).and_return(
          '/image/test.png'
        )
        main_image = ArticleImage.create(article_id: article.id, width: 200)
        ArticleImages::Import.any_instance.stub(:main_image).and_return(main_image)
        allow_any_instance_of(ArticleImages::Import).to receive(:create_main_image).and_return(main_image)

        Articles::FetchImages.call(article: article, blog: blog, mode: :import)

        expect(ArticleImage.count).to eq(1)
        expect(article.reload.body.index('/image/test.png')).to be_truthy
      end
    end
  end
end
