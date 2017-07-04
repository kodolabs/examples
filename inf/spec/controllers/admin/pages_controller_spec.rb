require 'rails_helper'

describe Admin::PagesController, type: :controller do
  let(:admin) { create(:admin) }
  let(:page) { create(:page) }

  context 'update posts' do
    specify 'success' do
      sign_in(admin)
      expect_any_instance_of(Page::Update).to receive(:call)

      put :sync, params: { id: page.id }
      expect(response).to redirect_to(admin_root_path)
      expect(flash[:notice]).to eq 'Source has been scheduled for an update'
    end
  end
end
