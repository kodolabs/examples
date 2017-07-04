require 'rails_helper'

describe DashboardsHelper do
  context 'header' do
    specify 'format numbers' do
      expect(helper.format_numbers(14_521)).to eq('14.5k')
      expect(helper.format_numbers(8312)).to eq('8,312')
    end
  end
end
