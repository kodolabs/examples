require 'rails_helper'

feature 'FAQ page' do
  it 'navigate-able from homepage' do
    visit '/'
    expect(page).to have_link('FAQ', href: faq_path)
  end
end
