require 'rails_helper'

feature Poll do
  let!(:user) { create :user, :organiser }
  let!(:event) { create :event, :active, creator: user }
  let!(:profile) { create :profile, :organiser, user: user, event: event }
  let!(:poll) { create :poll, event: event }

  describe 'with nested attributes' do
    it 'should accept model to create' do
      expect do
        Poll.create(question: 'question',
                    answers_attributes: {
                      '0': { 'position': 2, 'value': 'value' },
                      '1': { 'position': 2, 'value': 'value' },
                      '2': { 'position': 2, 'value': 'value' },
                      '3': { 'position': 2, 'value': 'value' },
                      '4': { 'position': 2, 'value': 'value' },
                      '5': { 'position': 2, 'value': 'value' }
                    })
      end.to change { Answer.count }.by(6)
    end

    it 'should fail when attributes more then 6' do
      expect do
        Poll.create(question: 'question',
                    answers_attributes: {
                      '0': { 'position': 2, 'value': 'value' },
                      '1': { 'position': 2, 'value': 'value' },
                      '2': { 'position': 2, 'value': 'value' },
                      '3': { 'position': 2, 'value': 'value' },
                      '4': { 'position': 2, 'value': 'value' },
                      '5': { 'position': 2, 'value': 'value' },
                      '6': { 'position': 2, 'value': 'value' }
                    })
      end.to raise_error(ActiveRecord::NestedAttributes::TooManyRecords)
    end
  end
end
