require 'rails_helper'

describe Admin::BannedKeywordsController, type: :controller do
  let(:admin) { create(:admin) }
  let(:keyword) { create(:banned_keyword) }

  context 'destroy keywords' do
    specify 'success' do
      sign_in(admin)
      keyword
      expect { delete :destroy, params: { id: keyword.id } }
        .to change(BannedKeyword, :count).from(1).to(0)
    end
  end
end
