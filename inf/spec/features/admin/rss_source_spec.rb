require 'rails_helper'

feature 'Admin Rss Sources' do
  let(:admin) { create :admin }
  before { admin_sign_in admin }

  specify 'can create new rss source' do
    visit admin_rss_sources_path
    find('.page-header a').click

    expect(SyncRssSourceWorker).to receive(:perform_async)

    within '#new_rss_source_' do
      fill_in 'Title', with: 'New RSS source title'
      fill_in 'URL', with: 'https://www.google.com/'
      choose 'Research'
      click_on 'Save'
    end

    expect(page).to have_flash('RSS source successfully created')
    expect(page).to have_content('New RSS source title')
    expect(page).to have_content('Research')
    expect(page).to have_link(nil, href: 'https://www.google.com/')
  end

  specify 'can update existing rss source' do
    rss_source = create(:rss_source)

    visit admin_rss_sources_path
    expect(page).to have_content(rss_source.title)
    expect(page).to have_link(nil, href: rss_source.url)

    click_on rss_source.title

    within 'form' do
      fill_in 'Title', with: 'Updated RSS source title'
      fill_in 'URL', with: 'https://www.google.com/'
      click_on 'Save'
    end

    expect(page).to have_current_path(admin_rss_sources_path)
    expect(page).to have_flash('RSS source successfully updated')
    expect(page).to have_content('Updated RSS source title')
    expect(page).to have_link(nil, href: 'https://www.google.com/')
  end

  specify 'can remove existing rss source' do
    rss_source = create(:rss_source)
    visit admin_rss_sources_path

    expect(page).to have_link(nil, href: rss_source.url)
    find('tbody tr:first-child a[data-method="delete"]').click

    expect(page).to have_current_path(admin_rss_sources_path)
    expect(page).to have_flash('RSS source successfully deleted')
    expect(page).not_to have_link(nil, href: rss_source.url)
  end

  context 'index' do
    let(:source1) { create(:rss_source, :with_topics) }
    let(:source2) { create(:rss_source) }
    let(:topics) { source1.topics }
    let(:topic1) { topics.first }
    let(:topic2) { topics.last }

    specify 'success' do
      source1
      source2
      visit admin_rss_sources_path
      expect(page).to have_content(source1.title)
      expect(page).to have_content(source2.title)
      expect(page).to have_content topic1.keyword
      expect(page).to have_content topic2.keyword
      expect(page).to have_content 'No topics'
    end
  end

  context 'edit source' do
    let!(:rss_source_1) { create :rss_source, kind: :research }
    let!(:rss_source_2) { create :rss_source, kind: :news }

    it 'kind selector setted with kind value' do
      visit edit_admin_rss_source_path(rss_source_1)
      kind = find(:radio_button, 'rss_source[kind]', checked: true).value
      expect(kind).to eq('research')

      visit edit_admin_rss_source_path(rss_source_2)
      kind = find(:radio_button, 'rss_source[kind]', checked: true).value
      expect(kind).to eq('news')
    end
  end
end
