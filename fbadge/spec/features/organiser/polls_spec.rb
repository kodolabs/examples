require 'rails_helper'

feature 'Polls' do
  let(:user) { create :user, :organiser }
  let(:event) { create :event, :active, creator: user }
  let!(:profile) { create :profile, :organiser, user: user, event: event }
  let!(:first_poll) { create :poll, event: event }
  let!(:second_poll) { create :poll, event: event, passing_date: Time.now + 2.days }
  let!(:first_answer) { create :answer, poll: first_poll, position: 1 }
  let(:second_answer) { create :answer, poll: second_poll }
  let!(:qrcodes_dir) { "#{Rails.root}/public/system/test/images/polls/".freeze }

  before do
    user.organiser.update_attribute(:eventbrite_token, 'sometoken')
    user_sign_in user
  end

  describe 'when organiser authorized' do
    describe 'list' do
      it 'should show in order with passing date first' do
        visit profile_event_polls_path(event)
        polls = page.all('.poll')
        expect(polls[0]).to have_content second_poll.question
        expect(polls[1]).to have_content first_poll.question
      end
    end
  end

  describe 'create' do
    before do
      visit new_profile_event_poll_path(event)

      const = 'DIR_PATH'
      qrcode_service = PollQrcodeService
      qrcode_service.send(:remove_const, const) if qrcode_service.const_defined?(const)
      qrcode_service.const_set(const, qrcodes_dir)
    end

    it 'should create poll with answers' do
      fill_in 'Question', with: 'Question'
      find('.poll_answers_value input').set('value')
      click_button 'Create Poll'
      expect(page).to have_content 'Poll successfully created'
    end

    it 'should create poll with 6 answers', js: true do
      fill_in 'Question', with: 'Question'
      find('.poll_answers_value input').set('value')
      5.times do |index|
        page.find('.add-answer').click
        polls = page.all('.fields')
        polls[index + 1].find('.poll_answers_value input').set('value')
      end
      click_button 'Create Poll'
      expect(page).to have_content 'Poll successfully created'
    end

    it 'should fail with long question and value' do
      fill_in 'Question', with: "Lorem Ipsum is simply dummy text of the printing and typesetting industry.
                              Lorem Ipsum has been the industry's standard dummy text ever since the 1500s,
                              when an unknown printer took a galley of type and scrambled it to make a type specimen book."

      find('.poll_answers_value input').set("Lorem Ipsum is simply dummy text of the printing and typesetting industry.
                              Lorem Ipsum has been the industry's standard dummy text ever since the 1500s,
                              when an unknown printer took a galley of type and scrambled it to make a type specimen book.")
      click_button 'Create Poll'
      expect(page).to have_content 'is too long (maximum is 80 characters)'
      expect(page).to have_content 'is too long (maximum is 20 characters)'
    end

    it 'should hide Add answers button when already 6 nested forms', js: true do
      5.times { page.find('.add-answer').click }
      expect(page).not_to have_selector '.add-answer'
    end
  end

  describe 'update' do
    it 'should update edit page' do
      visit edit_profile_event_poll_path(event, first_poll)
      expect(page).to have_field('Question', with: first_poll.question)
      find(".poll_answers_value input[value=#{first_answer.value}]")

      fill_in 'Question', with: 'Question'
      find('.poll_answers_value input').set('value')
      click_button 'Update Poll'

      expect(page).to have_content 'Poll successfully updated'
    end
  end

  describe 'show' do
    before do
      ticket_class = create :ticket_class, event: event
      badge = create :badge
      ticket = create :ticket, ticket_class: ticket_class, profile: profile
      registration = create :registration, badge: badge, profile: profile, ticket: ticket, event: event
      @second_answer = create :answer, poll: first_poll, position: 2
      @poll_session = create :poll_session, poll: first_poll
      vote = create :vote, poll_session_id: @poll_session.id, registration: registration
      create :vote_answer, vote: vote, answer: @second_answer
    end

    it 'should display answers with votes count' do
      visit profile_event_poll_path(event, first_poll)
      page.should have_css("img[src*='/system/images/polls/#{first_poll.id}.png']")
      answers = page.all('.answer')
      expect(answers[0]).to have_content first_answer.value
      expect(answers[1]).to have_content @second_answer.value
      expect(page).to have_content "Session #{@poll_session.position}"
    end

    it 'should display answers with votes count on session tab' do
      visit profile_event_poll_path(event, first_poll)
      answers = page.all('.answer')
      expect(answers[2]).to have_content first_answer.value
      expect(answers[2]).to have_content '0'
      expect(answers[3]).to have_content @second_answer.value
      expect(answers[3]).to have_content '1'
    end
  end
end
