require 'rails_helper'

describe FeaturedPages::Create do
  let!(:service) { FeaturedPages::Create }
  let!(:category) { create :category }
  let!(:provider) { providers(:facebook) }
  let(:source_service) { SourcePage::Present }
  let(:existing_service) { Pages::Existing }
  let(:page_info_service) { PageWorker }
  let(:form) { FeaturedPages::CreateFeaturedPageForm }

  context 'success' do
    context 'if page not present' do
      specify 'create featured page and page' do
        params = { 'create_featured_page' => {
          'title' => 'title',
          'category_ids' => ['', category.id.to_s],
          'provider' => provider.id.to_s,
          'handle_type' => 'handle',
          'handle' => 'kodolabs'
        } }
        allow_any_instance_of(form).to receive(:invalid?).and_return(false)
        allow_any_instance_of(source_service).to receive(:call).and_return(true)
        allow_any_instance_of(existing_service).to receive(:query).and_return(false)
        allow_any_instance_of(page_info_service).to receive(:perform)
        f = form.from_params(params)
        service.call(f)
        expect(Page.count).to eq(1)
        expect(FeaturedPage.count).to eq(1)
      end
    end
  end
end
