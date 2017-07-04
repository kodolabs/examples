require 'rails_helper'

describe DashboardDecorator do
  let!(:customer) { create :customer, :with_pro_subscription }
  let!(:user) { customer.primary_user }

  context 'with filters' do
    context 'with half year' do
      let(:dashboard) { Dashboard.new customer, user, last_months: '6' }
      let(:decorated) { DashboardDecorator.decorate dashboard }
      it '#time_range' do
        expect(decorated.time_range).to_not be_nil
      end
      it '#group_name' do
        expect(decorated.group_name).to eq I18n.t('customer.dashboard.report.header.groups')
      end
      it '#location_name' do
        expect(decorated.location_name).to eq I18n.t('customer.dashboard.report.header.locations')
      end
      it '#main_sources_percent' do
        expect(decorated.main_sources_percent).to eq 100
      end
      it '#main_sources' do
        expect(decorated.main_sources).to eq []
      end
      it '#reviews_without_rating' do
        expect(decorated.reviews_without_rating).to eq 0
      end
      it '#expanded_date_chart?' do
        expect(decorated.expanded_date_chart?).to be_falsy
      end
    end
    context 'with year' do
      let!(:dashboard) { Dashboard.new customer, user, last_months: '12' }
      let!(:decorated) { DashboardDecorator.decorate dashboard }
      it '#expanded_date_chart?' do
        expect(decorated.expanded_date_chart?).to be_falsy
      end
    end
    context 'with 2 year' do
      let!(:dashboard) { Dashboard.new customer, user, last_months: '24' }
      let!(:decorated) { DashboardDecorator.decorate dashboard }
      it '#expanded_date_chart?' do
        expect(decorated.expanded_date_chart?).to be_truthy
      end
    end
  end

  context 'with default settings' do
    let!(:dashboard) { Dashboard.new customer, user, last_months: nil }
    let!(:decorated) { DashboardDecorator.decorate dashboard }

    it '#time_range' do
      expect(decorated.time_range).to be_nil
    end
    it '#group_name' do
      expect(decorated.group_name).to eq I18n.t('customer.dashboard.report.header.groups')
    end
    it '#location_name' do
      expect(decorated.location_name).to eq I18n.t('customer.dashboard.report.header.locations')
    end
    it '#main_sources_percent' do
      expect(decorated.main_sources_percent).to eq 100
    end
    it '#main_sources' do
      expect(decorated.main_sources).to eq []
    end
    it '#reviews_without_rating' do
      expect(decorated.reviews_without_rating).to eq 0
    end
    it '#expanded_date_chart?' do
      expect(decorated.expanded_date_chart?).to be_falsy
    end
    it '#dates_for_select' do
      res = [
        OpenStruct.new(label: 'Last 6 months', value: 6),
        OpenStruct.new(label: 'Last year', value: 12),
        OpenStruct.new(label: 'Last 2 years', value: 24),
        OpenStruct.new(label: 'Custom date', value: -1)
      ]
      expect(decorated.dates_for_select).to match_array res
    end
  end
end
