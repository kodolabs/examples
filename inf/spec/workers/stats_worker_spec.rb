require 'rails_helper'

describe StatsWorker do
  context 'success' do
    specify 'fetch stats' do
      expect_any_instance_of(Page::SaveStats).to receive(:call)
      StatsWorker.new.perform(page_id: 1)
    end
  end
end
