require 'rails_helper'

describe Shares::Commands::PublishLinkedin do
  let(:service) { Shares::Commands::PublishLinkedin }
  let(:account) { create(:account, :with_linkedin_page) }
  let(:owned_page) { account.owned_pages.last }
  let(:page) { account.pages.last }
  let(:api) { Linkedin::Posts }
  context 'success' do
    specify 'plain text' do
      text = 'awesome'
      data = OpenStruct.new(message: text)
      allow_any_instance_of(api).to receive(:create).with(page.uid, text: text)
        .and_return('updateKey' => 'aa')
      service.new(owned_page).call(data)
    end

    specify 'with image' do
      image_url = 'http://google.com/image.jpg'
      text = 'some text'
      data = OpenStruct.new(message: text, image_urls: [image_url])
      allow_any_instance_of(api).to receive(:create).with(page.uid, text: text, image_url: image_url)
        .and_return('updateKey' => 'aa')
      service.new(owned_page).call(data)
    end
  end
end
