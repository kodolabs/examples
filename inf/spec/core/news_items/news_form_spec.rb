require 'rails_helper'

describe NewsItems::NewsForm do
  let(:form) { NewsItems::NewsForm }
  let(:valid_params) do
    {
      news: {
        topic_ids: [],
        title: FFaker::Lorem.word,
        description: FFaker::Lorem.paragraph,
        url: FFaker::Internet.http_url,
        image: nil,
        remote_image_url: nil,
        favicon: nil,
        kind: :research,
        source_title: FFaker::Lorem.word
      }
    }
  end
  let(:existing_form) { form.from_params(valid_params) }
  let(:image) do
    Rack::Test::UploadedFile.new(
      Rails.root.join('spec', 'fixtures', 'images', 'customer_logo.jpg')
    )
  end

  def params(attrs = {})
    valid_params.deep_merge(news: attrs)
  end

  specify 'with valid params' do
    expect(form.from_params(params).valid?).to be_truthy
  end

  specify 'model attributes' do
    attrs = valid_params[:news].except(:image)
    expect(existing_form.model_attributes).to eq attrs
  end

  specify 'preview image class' do
    form = existing_form.dup
    expect(form.preview_image_class).to eq 'hidden'
    form.remote_image_url = 'http://google.com/image.jpg'
    expect(form.preview_image_class).to eq ''
  end

  context 'image tab class' do
    specify 'remote image url present' do
      form = existing_form.dup
      form.remote_image_url = 'http://google.com/image.jpg'
      expect(form.image_tab_class(:url)).to eq 'active'
      expect(form.image_tab_class(:file)).to be_blank
    end

    specify 'remote image url is empty' do
      form = existing_form.dup
      expect(form.image_tab_class(:url)).to eq ''
      expect(form.image_tab_class(:file)).to eq 'active'
    end
  end

  specify 'image extensions' do
    stub_const('NewsImageUploader::EXTENSIONS', %w(image/jpeg image/png))
    expect(existing_form.image_extensions).to eq 'image/jpeg,image/png'
  end

  specify 'max image size' do
    stub_const('NewsImageUploader::MAX_SIZE', 10)
    expect(existing_form.max_image_size).to eq 10
  end

  context 'cache' do
    specify 'local image' do
      form = existing_form.dup
      form.image = image
      form.remote_image_url = nil
      form.cache_image
      expect(form.image_url).to include('customer_logo.jpg')
      expect(form.image_cache).to be_truthy
      expect(form.image_path).to include('customer_logo.jpg')
    end
    specify 'from url' do
      form = existing_form.dup
      form.remote_image_url = 'http://google.com/image.png'
      form.image = nil

      fake_image = double('image')

      allow(fake_image).to receive(:url) { 'image.png' }
      allow(fake_image).to receive(:path) { 'image.png' }
      allow_any_instance_of(News).to receive(:image_cache) { true }
      allow_any_instance_of(News).to receive(:image) { fake_image }
      form.cache_image
      expect(form.image_url).to include('image.png')
      expect(form.image_cache).to be_truthy
      expect(form.image_path).to include('image.png')
    end
  end

  context 'validation' do
    context 'image size' do
      specify 'success' do
        form = existing_form.dup
        form.image_path = '/image.png'
        form.remote_image_url = 'http://google.com/image.png'
        allow(File).to receive(:size) { 1 }
        allow(form).to receive(:max_image_size) { 2 }
        expect(form.valid?).to be_truthy
      end

      specify 'fail' do
        form = existing_form.dup
        form.image_path = '/image.png'
        form.remote_image_url = 'http://google.com/image.png'
        allow(File).to receive(:size) { 3 * 1024 * 1024 }
        allow(form).to receive(:max_image_size) { 2 * 1024 * 1024 }
        expect(form.valid?).to be_falsey
      end
    end

    context 'html' do
      specify 'success' do
        form = existing_form.dup
        form.title = 'Some title'
        expect(form.valid?).to be_truthy
      end

      specify 'special characters' do
        form = existing_form.dup
        form.description = 'hypoglycemia (P < .05 for all)'
        expect(form.valid?).to be_truthy
      end

      specify 'fail' do
        form = existing_form.dup
        form.title = '<div></div>'
        form.description = '<div></div>'
        expect(form.valid?).to be_falsey
        expect(form.errors.full_messages).to include 'Title contains html', 'Description contains html'
      end
    end

    context 'url uniqueness' do
      let(:news) { create(:news, url: 'http://google.com') }

      specify 'success' do
        form = existing_form.dup
        form.url = 'http://google.com'
        expect(form.valid?).to be_truthy
      end

      specify 'fail' do
        form = existing_form.dup
        form.url = news.url
        expect(form.valid?).to be_falsey
        expect(form.errors.full_messages).to include 'Url has already been taken'
      end
    end
  end
end
