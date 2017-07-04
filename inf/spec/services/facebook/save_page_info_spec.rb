require 'rails_helper'

describe Facebook::SavePageInfo do
  let(:page) { create(:page, :test) }

  context 'success', :stub_facebook_auth do
    specify 'save page info' do
      graph = double('graph')
      api_result = OpenStruct.new(
        picture: OpenStruct.new(data: OpenStruct.new(url: 'logo')),
        cover: OpenStruct.new(source: 'background'),
        name: 'strange title',
        description: 'some description',
        about: 'some about info'
      )
      allow(graph).to receive(:get_object).and_return(api_result)
      allow_any_instance_of(Facebook::Service).to receive(:graph).and_return(graph)
      Facebook::SavePageInfo.new(page).call
      updated_page = page.reload

      expect(updated_page.logo).to eq(api_result.picture.data.url)
      expect(updated_page.background_image).to eq(api_result.cover.source)
      expect(updated_page.title).to eq(api_result.name)
      expect(updated_page.description).to eq(api_result.about)
    end
  end
end
