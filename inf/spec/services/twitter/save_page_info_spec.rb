require 'rails_helper'

describe Twitter::SavePageInfo do
  context 'success' do
    let(:page) { create(:page, :twitter, handle: 'sferik', handle_type: 'handle') }

    specify 'handle' do
      api_result = OpenStruct.new(
        profile_image_url: 'image1.jpg',
        background_image: 'image2.jpg',
        name: 'Title',
        description: 'Some description'
      )
      allow_any_instance_of(Twitter::Service).to receive(:fetch_user_info).and_return(api_result)
      Twitter::SavePageInfo.new(page).call
      updated_page = page.reload

      expect(updated_page.logo).to eq(api_result.profile_image_url)
      expect(updated_page.background_image).to eq(api_result.profile_banner_url)
      expect(updated_page.title).to eq(api_result.name)
      expect(updated_page.description).to eq(api_result.description)
    end
  end

  context 'fail' do
    let(:page) { create(:page, :twitter, :hashtag) }

    specify 'hashtag' do
      allow_any_instance_of(Twitter::Service).to receive(:fetch_user_info).and_raise(StandardError)
      Twitter::SavePageInfo.new(page).call
      updated_page = page.reload

      expect(updated_page.background_image).to be_falsey
      expect(updated_page.title).to be_falsey
      expect(updated_page.description).to be_falsey
    end
  end
end
