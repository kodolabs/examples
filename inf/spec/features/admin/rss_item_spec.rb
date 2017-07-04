require 'rails_helper'

feature 'Admin Rss Items' do
  let(:admin) { create :admin }
  before { admin_sign_in admin }

  specify 'can see all rss items' do
    visit admin_rss_items_path

    expect(page).to have_content('No RSS items')

    news_source = create :rss_source, kind: :news
    research_source = create :rss_source, kind: :research
    rss_item1 = create :rss_item, status: :unread, image_url: nil, rss_source: news_source
    rss_item2 = create :rss_item, status: :unread, image_url: nil, rss_source: research_source

    visit admin_rss_items_path

    expect(page).to have_content(rss_item1.title)
    expect(page).to have_content(rss_item1.author)
    expect(page).to have_content(rss_item1.rss_source.title)

    expect(page).to have_content(rss_item2.title)
    expect(page).to have_content(rss_item2.author)
    expect(page).to have_content(rss_item2.rss_source.title)
  end

  specify 'can see only news rss items' do
    visit admin_rss_items_path(kind: :news)

    expect(page).to have_content('No RSS items')

    news_source = create :rss_source, kind: :news
    research_source = create :rss_source, kind: :research
    rss_item1 = create :rss_item, status: :unread, image_url: nil, rss_source: news_source
    rss_item2 = create :rss_item, status: :unread, image_url: nil, rss_source: research_source

    visit admin_rss_items_path(kind: :news)

    expect(page).to have_content(rss_item1.title)
    expect(page).to have_content(rss_item1.author)
    expect(page).to have_content(rss_item1.rss_source.title)

    expect(page).to_not have_content(rss_item2.title)
    expect(page).to_not have_content(rss_item2.author)
    expect(page).to_not have_content(rss_item2.rss_source.title)
  end

  specify 'can see only research rss items' do
    visit admin_rss_items_path(kind: :research)

    expect(page).to have_content('No RSS items')

    news_source = create :rss_source, kind: :news
    research_source = create :rss_source, kind: :research
    rss_item1 = create :rss_item, status: :unread, image_url: nil, rss_source: news_source
    rss_item2 = create :rss_item, status: :unread, image_url: nil, rss_source: research_source

    visit admin_rss_items_path(kind: :research)

    expect(page).to_not have_content(rss_item1.title)
    expect(page).to_not have_content(rss_item1.author)
    expect(page).to_not have_content(rss_item1.rss_source.title)

    expect(page).to have_content(rss_item2.title)
    expect(page).to have_content(rss_item2.author)
    expect(page).to have_content(rss_item2.rss_source.title)
  end

  specify 'can see only unread rss items' do
    unread_item = create :rss_item, status: :unread
    skipped_item = create :rss_item, status: :skipped
    saved_item = create :rss_item, status: :saved

    visit admin_rss_items_path

    expect(page).to have_content(unread_item.title)
    expect(page).to_not have_content(skipped_item.title)
    expect(page).to_not have_content(saved_item.title)

    expect(page.all('.rss-item').count).to eq(1)
  end

  specify 'skip item', js: true do
    unread_item = create :rss_item, status: :unread, image_url: nil

    visit admin_rss_items_path
    expect(page).to have_content(unread_item.title)

    page.accept_confirm do
      find('.rss-item:first-child .rss-item-delete-link').click
    end

    expect(page).to_not have_content(unread_item.title)
  end

  specify 'skip item in modal', js: true do
    unread_item = create :rss_item, status: :unread, image_url: nil

    visit admin_rss_items_path
    expect(page).to have_content(unread_item.title)

    find('.rss-item:first-child.rss-item-show-link').click

    page.accept_confirm do
      find('#show-rss-item-modal .rss-item-delete-link').click
    end

    expect(find('#rss-items-table')).to_not have_content(unread_item.title)
  end

  specify 'show item in modal', js: true do
    unread_item = create :rss_item, status: :unread, image_url: nil

    visit admin_rss_items_path
    expect(page).to have_content(unread_item.title)

    find('.rss-item:first-child.rss-item-show-link').click

    expect(find('#show-rss-item-modal')).to have_content(unread_item.title)
  end

  specify 'try save item without topics', js: true do
    unread_item = create :rss_item, status: :unread, image_url: nil

    visit admin_rss_items_path
    expect(page).to have_content(unread_item.title)

    find('.rss-item:first-child.rss-item-show-link').click
    find('#show-rss-item-modal .rss-item-save-link').click

    find('#show-rss-item-modal .btn-save').click

    expect(find('#show-rss-item-modal')).to have_content("Topics can't be empty.")
    expect(find('#show-rss-item-modal')).to have_content(unread_item.title)
  end

  skip 'save item', js: true do
    unread_item = create :rss_item, status: :unread, image_url: nil
    topic = create :topic, keyword: 'test'

    visit admin_rss_items_path
    expect(page).to have_content(unread_item.title)

    find('.rss-item:first-child.rss-item-show-link').click
    find('#show-rss-item-modal .rss-item-save-link').click

    select_option('topics-selectize', topic.keyword)

    find('#show-rss-item-modal .btn-save').click

    expect(page).to_not have_content("Topics can't be empty.")
    expect(find('#rss-items-table')).to_not have_content(unread_item.title)
  end
end
