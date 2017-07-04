require 'rails_helper'

describe Publication do
  context 'disconnected target' do
    specify 'dont raise delegation error' do
      owned_page = create(:owned_page, account: nil)
      pub = create(:publication, owned_page: owned_page)
      expect(pub.provider).to be_blank
    end
  end
end
