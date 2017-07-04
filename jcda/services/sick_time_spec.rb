require 'rails_helper'

RSpec.describe SickTime, type: :service do
  let(:user) { create :user }

  before { Timecop.freeze(Time.current) }
  after { Timecop.return }

  describe '.init' do
    it 'creates SickTimeJournal item for 10 sick hours' do
      expect do
        SickTime.new(user).init
      end.to change(SickTimeJournal, :count).from(0).to(1)

      time_journal_item = SickTimeJournal.last

      expect(time_journal_item.user).to eql user
      expect(time_journal_item.period_start.to_s).to eql Time.current.beginning_of_year.to_s
      expect(time_journal_item.period_end.to_s).to eql Time.current.to_s
      expect(time_journal_item.amount).to eql SickTime::DEFAULT_AMOUNT
      expect(time_journal_item.initial?).to be_truthy

      expect(user.reload.remaining_sick_time).to eql SickTime::DEFAULT_AMOUNT
    end
  end

  describe '.yearly' do
    context 'user have less 40 sick times' do
      before do
        create :sick_time_journal,
          user: user,
          period_start: (Time.current - 1.year).beginning_of_year,
          period_end: Time.now - 1.year

        create :sick_time_journal, user: user, amount: 5.0
        create :sick_time_journal, user: user, amount: 12.0
      end
      it 'creates new sick time journal' do
        expect do
          SickTime.new(user).yearly
        end.to change(SickTimeJournal, :count).from(3).to(4)

        time_journal_item = SickTimeJournal.last

        expect(time_journal_item.user).to eql user
        expect(time_journal_item.period_start.to_s).to eql user.last_auto_sick_time_journal.period_end.to_s
        expect(time_journal_item.period_end.to_s).to eql Time.current.to_s
        expect(time_journal_item.amount).to eql 17.0
        expect(time_journal_item.initial?).to be_truthy

        expect(user.reload.remaining_sick_time).to eql 17.0
      end
    end

    context 'user have more 40 sick times' do
      before do
        create :sick_time_journal,
          user: user,
          period_start: (Time.current - 1.year).beginning_of_year,
          period_end: Time.now - 1.year

        create :sick_time_journal, user: user, amount: 65.0
      end
      it 'creates new sick time journal' do
        expect(user.reload.remaining_sick_time).to eql 65.0

        expect do
          SickTime.new(user).yearly
        end.to change(SickTimeJournal, :count).from(2).to(3)

        time_journal_item = SickTimeJournal.last

        expect(time_journal_item.user).to eql user
        expect(time_journal_item.period_start.to_s).to eql user.last_auto_sick_time_journal.period_end.to_s
        expect(time_journal_item.period_end.to_s).to eql Time.current.to_s
        expect(time_journal_item.amount).to eql 40.0
        expect(time_journal_item.initial?).to be_truthy

        expect(user.reload.remaining_sick_time).to eql 40.0
      end
    end
  end

  describe '.auto' do
    context 'for hourly user' do
      before do
        create :sick_time_journal, user: user, period_end: 10.days.ago
        create :time_log, user: user, clock_in: 40.hours.ago, clock_out: 20.hours.ago
        create :time_log, user: user, clock_in: 80.hours.ago, clock_out: 60.hours.ago
        create :time_log, :opened, user: user
      end

      it 'creates SickTimeJournal item with amount based on unaccounted time_logs' do
        # expected_amount = user.time_logs.map(&:total).reduce(&:+) * 1.0/40
        SickTime.new(user).auto

        time_journal_item = SickTimeJournal.last

        expect(time_journal_item.amount).to eql 1.0
      end

      it 'updates user#remaining_sick_time' do
        SickTime.new(user).auto
        expect(user.reload.remaining_sick_time).to eql 1.0 + SickTime::DEFAULT_AMOUNT
      end
    end

    context 'for salaried user' do
      before do
        create :sick_time_journal, user: user, period_end: 168.hours.ago
        user.salaried!
      end

      it 'creates new period range based SickTimeJournal item' do
        # expected_amount = (Time.now - user.last_time_journal.period_end) * 1.0/(168 * 60 * 60)
        SickTime.new(user).auto

        time_journal_item = SickTimeJournal.last

        expect(time_journal_item.amount).to eql 1.0
      end

      it 'updates user#remaining_sick_time' do
        SickTime.new(user).auto
        expect(user.reload.remaining_sick_time).to eql 1.0 + SickTime::DEFAULT_AMOUNT
      end
    end
  end

  describe '.use' do
    let!(:init_time_journal) { create :sick_time_journal, user: user, amount: 10 }
    let!(:request) { create :request, user: user, request_type: :sick, amount: 4.5 }

    it 'creates new SickTimeJournal with negative amount' do
      expect do
        SickTime.new(user).use(request)
      end.to change { user.reload.remaining_sick_time }.from(10.0).to(5.5)

      time_journal = user.sick_time_journals.last
      expect(time_journal.use?).to be_truthy
      expect(time_journal.amount).to eql -4.5
    end
  end
end
