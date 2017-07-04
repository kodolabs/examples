require 'rails_helper'

describe SourcePagesDecorator do
  let(:feed) { create(:feed) }
  let(:page_1) { create(:source_page, title: 'Awesome page', feed: feed) }
  let(:page_2) { create(:source_page, title: 'Another page', feed: feed) }

  specify 'values for select' do
    page_1
    page_2

    values = [[page_1.title, page_1.page.id], [page_2.title, page_2.page.id]]
    expect(feed.source_pages.decorate.values_for_select).to match_array(values)
  end
end
