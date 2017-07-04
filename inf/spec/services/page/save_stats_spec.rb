require 'rails_helper'

describe Page::SaveStats do
  context 'facebook' do
    context 'success' do
      let(:page) { create(:page) }
      specify 'fetch stats' do
        options = { 'page_id' => page.id, 'provider' => 'facebook' }
        expect_any_instance_of(Facebook::FetchStats).to receive(:call)
        Page::SaveStats.new(options).call
      end
    end
  end

  context 'twitter' do
    context 'success' do
      specify 'fetch stats' do
        options = { 'handles' => %w(sferik user), 'provider' => 'twitter' }
        expect_any_instance_of(Twitter::SavePageStats).to receive(:call)
        Page::SaveStats.new(options).call
      end
    end
  end
end
