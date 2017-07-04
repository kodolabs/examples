require 'rails_helper'

feature 'Home Page' do
  it 'should be available' do
    visit '/'
    expect(page).to have_content 'MEDeTOURISM'
  end
end
