require 'rails_helper'

describe InitialStatsWorker do
  context 'success' do
    let(:page) { create(:page) }

    specify 'fetch stats' do
      page
      expect_any_instance_of(Facebook::FetchStats).to receive(:call)
      InitialStatsWorker.new.perform(page.id)
    end
  end
end
