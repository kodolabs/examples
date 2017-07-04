require 'rails_helper'

feature 'Alerts' do
  let!(:domain1) do
    create(:domain, name: 'http://amazon.com', status: :active, expires_at: Time.zone.now + 1.day)
  end
  let!(:domain2) do
    create(:domain, name: 'http://google.com', status: :active, expires_at: Time.zone.now + 1.day)
  end

  before { user_sign_in }

  describe 'index page' do
    context 'without alerts' do
      it 'should show message' do
        visit alerts_path
        expect(page).to have_content I18n.t('alerts.index.empty')
      end
    end

    context 'with alerts' do
      before do
        @alert1 = create(:alert, :reindexed, alertable: domain1).decorate
        @alert2 = create(:alert, :deindexed, alertable: domain2).decorate
        visit alerts_path
      end

      it 'should show list' do
        expect(page).to have_content @alert1.human_kind
        expect(page).to have_content @alert1.description
        expect(page).to have_content @alert2.human_kind
        expect(page).to have_content @alert2.description
        expect(page).to have_content 'Showing all 2 alerts'
      end

      it 'clear button should destroy all alerts' do
        expect(page).to have_content 'Showing all 2 alerts'
        click_link I18n.t('alerts.clear')
        expect(page).to have_flash I18n.t('notifications.alerts_deleted')
        expect(page).to have_content I18n.t('alerts.index.empty')
      end
    end
  end

  describe 'top nav' do
    context 'without alerts' do
      it 'should show message' do
        visit root_path
        within('div.menu-extras') do
          expect(page).to have_content I18n.t('alerts.index.empty')
        end
      end
    end

    context 'with alerts' do
      it 'should show list' do
        alert1 = create(:alert, :reindexed, alertable: domain1).decorate
        alert2 = create(:alert, :deindexed, alertable: domain2).decorate
        visit root_path
        within('div.menu-extras') do
          expect(page).to have_content alert1.human_kind
          expect(page).to have_content alert1.description
          expect(page).to have_content alert2.human_kind
          expect(page).to have_content alert2.description
        end
      end
    end
  end
end
