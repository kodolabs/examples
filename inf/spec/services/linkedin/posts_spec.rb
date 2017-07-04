require 'rails_helper'

describe Linkedin::Posts do
  let(:service) { Linkedin::Posts }
  let(:page) { create(:page, :linkedin, :with_linkedin_account) }
  let(:token) { page.decorate.linkedin_api_token }
  let(:api) { service.new(token) }
  let(:uid) { page.uid }

  context 'create' do
    context 'success' do
      let(:endpoint) { "companies/#{uid}/shares" }
      let(:body) { { 'a' => 1 } }
      let(:image_url) { 'http://google.com/image.jpg' }
      let(:text) { 'some text' }
      let(:url) { 'http://google.com' }

      let(:default_api_params) do
        {
          comment: text,
          visibility: { code: :anyone },
          content: {
            'submitted-url' => "https://#{ENV['HOST_NAME']}",
            'description' => '',
            'title' => 'Influenza AI',
            'submitted-image-url' => image_url
          }
        }
      end

      def params(attrs = {})
        default_api_params.deep_merge(attrs)
      end

      specify 'plain post' do
        api_params = {
          comment: text,
          visibility: { code: :anyone }
        }
        allow_any_instance_of(service).to receive(:post).and_return(body)
        expect_any_instance_of(service).to receive(:post).with(endpoint, api_params)
        options = { text: text }
        res = api.create(uid, options)
        expect(res).to eq(body)
      end

      specify 'post with image' do
        api_params = params
        allow_any_instance_of(service).to receive(:post).and_return(body)
        expect_any_instance_of(service).to receive(:post).with(endpoint, api_params)
        options = {
          text: text,
          image_url: image_url
        }
        res = api.create(uid, options)
        expect(res).to eq(body)
      end

      specify 'custom post with opengraph' do
        title = 'Awesome title'
        description = 'Awesome desc'
        api_params = params(
          content: {
            'submitted-url' => url,
            'description' => description,
            'title' => title,
            'submitted-image-url' => image_url
          }
        )
        allow_any_instance_of(service).to receive(:post).and_return(body)
        expect_any_instance_of(service).to receive(:post).with(endpoint, api_params)
        options = {
          text: text,
          image_url: image_url,
          title: title,
          description: description,
          url: url
        }
        res = api.create(uid, options)
        expect(res).to eq(body)
      end

      specify 'truncate text' do
        long_text = FFaker::Lorem.characters(710)
        api_params = {
          comment: long_text.truncate(700),
          visibility: { code: :anyone }
        }
        allow_any_instance_of(service).to receive(:post).and_return(body)
        expect_any_instance_of(service).to receive(:post).with(endpoint, api_params)
        options = { text: long_text }
        res = api.create(uid, options)
        expect(res).to eq(body)
      end
    end

    context 'fail' do
      let(:api_error) { Linkedin::ApiException }
      let(:auth_error) { Linkedin::AuthException }

      specify 'api params are invalid' do
        stub_request(:post, /.*linkedin.com.*/)
          .to_return(status: 400)
        expect { api.create(uid, text: nil) }.to raise_error(api_error)
      end

      specify 'token is invalid' do
        stub_request(:post, /.*linkedin.com.*/)
          .to_return(status: 401)
        expect { api.create(uid, text: nil) }.to raise_error(auth_error)
      end
    end
  end
end
