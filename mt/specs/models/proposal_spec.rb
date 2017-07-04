require 'rails_helper'

describe Proposal do
  describe 'price' do
    subject do
      Proposal.create(
        enquiry: create(:enquiry, :proposed),
        proposal_procedures_attributes: [
          { procedure: create(:procedure), price: 123.0 },
          { procedure: create(:procedure), price: 321.0 }
        ]
      )
    end

    context 'when proposal created' do
      it 'should save proper price' do
        expect(subject.price).to eq 444.0
      end
    end

    context 'when proposal_procedure updated' do
      it 'should update price' do
        subject.proposal_procedures.first.update(price: 1000)
        expect(subject.reload.price).to eq 1321.0
      end
    end
  end

  describe 'start_date_set_on' do
    let!(:enquiry) { create(:enquiry, :proposed) }
    let!(:proposal) { create(:proposal, start_date_set_on: 2.weeks.ago, enquiry: enquiry) }

    it 'should set value on create' do
      expect(proposal.start_date_set_on).to eq 2.weeks.ago.to_date
    end

    it 'should update value on start_date change' do
      proposal.update_attribute(:start_date, 3.days.from_now)
      expect(proposal.start_date_set_on).to eq Date.today
    end

    it 'should not update value when start_date was not changed' do
      proposal.update_attribute(:price, 987.21)
      expect(proposal.start_date_set_on).to eq 2.weeks.ago.to_date
    end
  end

  describe 'schedule_date' do
    context 'correct usage' do
      let!(:start_date) { 2.weeks.from_now }
      let!(:small_timeout) { 1.week }
      let!(:big_timeout) { 3.weeks }
      let!(:start_date_changed_on) { 2.days.ago.to_date } # so called `today`
      let!(:enquiry) { create(:enquiry, :proposed) }
      let!(:proposal) { create(:proposal, start_date: start_date, start_date_set_on: start_date_changed_on, enquiry: enquiry) }

      context 'when `today` is less than three days before start_date' do
        it 'should return nil' do
          proposal = create(:proposal, start_date: 2.days.from_now, enquiry: enquiry)
          expect(proposal.schedule_date(small_timeout)).to be_nil
        end
      end

      context 'when `today` is earlier than timed out start_date' do
        it 'should return timed out start_date' do
          expect(proposal.schedule_date(small_timeout)).to eq proposal.start_date - small_timeout
        end
      end

      context 'when `today` is after timed out start_date' do
        it 'should return `today`' do
          expect(proposal.schedule_date(big_timeout)).to eq start_date_changed_on
        end
      end
    end
  end
end
