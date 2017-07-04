require 'rails_helper'

describe 'Headers' do
  context 'X-Robots-Tag' do
    specify 'success' do
      ClimateControl.modify IGNORE_GOOGLE_INDEX: '1' do
        visit root_path
        expect(page.response_headers['X-Robots-Tag']).to be_truthy
      end
    end

    specify 'fail' do
      visit root_path
      expect(page.response_headers['X-Robots-Tag']).to be_falsey
    end
  end
end
