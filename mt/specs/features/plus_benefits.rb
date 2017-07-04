require 'rails_helper'

feature 'PLUS+ Page' do
  it 'navigate-able from homepage' do
    visit '/'
    expect(page).to have_link('MEDeTOURISM PLUS+', href: plus_benefits_path)
  end
end
