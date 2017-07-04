require 'rails_helper'

describe SourcePages::Destroy do
  let(:page) { create(:source_page) }

  context 'success' do
    specify 'remove source page' do
      page
      expect { SourcePages::Destroy.new(page).call }.to change(SourcePage, :count).to(0)
    end
  end
end
