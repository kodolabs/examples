require 'rails_helper'

describe Linkedin::SavePageInfo do
  let(:page) { create(:page, :linkedin, :with_linkedin_account) }

  context 'success' do
    let(:service) { Linkedin::SavePageInfo }
    let(:api_service) { Linkedin::Pages }

    specify 'save page info' do
      api_result = OpenStruct.new(
        logoUrl: 'http://linkedin/image.jpg',
        name: 'some name',
        description: 'some desc'
      )
      allow_any_instance_of(api_service).to receive(:info).and_return(api_result)
      service.new(page).call
      updated_page = page.reload

      expect(updated_page.logo).to eq(api_result.logoUrl)
      expect(updated_page.background_image).to be_falsey
      expect(updated_page.title).to eq(api_result.name)
      expect(updated_page.description).to eq(api_result.description)
    end
  end
end
