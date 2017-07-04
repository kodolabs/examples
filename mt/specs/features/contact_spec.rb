require 'rails_helper'

feature 'Contact page' do
  it 'navigate-able from homepage' do
    visit '/'
    expect(page).to have_link('Contact', href: contact_path)
  end

  before do
    visit contact_path
    fill_in 'contact_form_name', with: 'John'
    fill_in 'contact_form_subject', with: 'New message'
    fill_in 'contact_form_message', with: 'Lorem ipsum dolor sit Ammet'
  end

  context 'when js not enabled' do
    before { select 'United Kingdom', from: 'contact_form_country' }

    context 'with filled inputs' do
      it 'should send message' do
        fill_in 'contact_form_email', with: 'test@gmail.com'
        click_on 'Send'
        expect(page).to have_content 'Email sent to MEDeTOURISM team'
      end

      it 'should not send message with invalid contact email' do
        fill_in 'contact_form_email', with: 'test@gmai'
        click_on 'Send'
        expect(page).to have_content 'Can\'t send email'
      end
    end

    context 'without filled input' do
      it 'should not send message' do
        click_on 'Send'
        expect(page).to have_content 'Can\'t send email'
      end
    end
  end

  context 'when js enabled', :js do
    context 'with filled inputs' do
      before { select_option('contact_form_country', 'United Kingdom') }

      it 'should send message' do
        fill_in 'contact_form_email', with: 'test@gmail.com'
        click_on 'Send'
        expect(page).to have_content 'Email sent to MEDeTOURISM team'
      end

      it 'should not send message with invalid contact email' do
        fill_in 'contact_form_email', with: 'test@gmai'
        click_on 'Send'
        expect(page).to have_content 'Please fix errors above'
      end
    end

    context 'without filled input' do
      it 'should not send message' do
        click_on 'Send'
        expect(page).to have_content 'Please fix errors above'
      end
    end
  end
end
