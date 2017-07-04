require 'rails_helper'

RSpec.describe VacationTime, type: :service do
  let(:user) { create :user, vacation: 36 }

  before { Timecop.freeze(Date.new(2015, 4, 1)) }
  after { Timecop.return }

  describe '.init' do
    it "creates initial time_journal record for user" do
      expect do
        VacationTime.new(user).init
      end.to change(TimeJournal, :count).from(0).to(1)
    end

    describe 'set initial time_jouranals attributes' do
      specify "period_start to beginning of year period_end to today" do
        VacationTime.new(user).init

        time_journal_item = VacationTimeJournal.last
        expect(time_journal_item.period_start.to_s).to eql Time.current.beginning_of_year.to_s
        expect(time_journal_item.period_end.to_s).to eql Time.current.to_s
      end

      describe 'amount for manager' do
        specify 'set amount proportionally to remaining time of the year' do
          VacationTime.new(user).init

          expect(VacationTimeJournal.last.amount).to eql 27.12
          expect(user.reload.remaining_vacation_time).to eql 27.12
        end
      end
    end
  end

  describe '.use' do
    let!(:init_time_journal) { create :vacation_time_journal, user: user, amount: 10 }
    let!(:request) { create :request, user: user, request_type: :paid_vacation, amount: 4.5 }

    it 'creates new VacationTimeJournal with negative amount' do
      expect do
        VacationTime.new(user).use(request)
      end.to change { user.reload.remaining_vacation_time }.from(10.0).to(5.5)

      time_journal = user.vacation_time_journals.last
      expect(time_journal.use?).to be_truthy
      expect(time_journal.amount).to eql -4.5
    end
  end

  describe '.yearly' do
    let(:manager) { create :super_user, vacation: 40 }
    let(:technician) { create :user, vacation: 36, role: create(:role, :technician), parent: manager }
    let(:init_vacation_for_manager) { create :vacation_time_journal, user: manager, amount: 50.0 }
    let(:init_vacation_for_technician) { create :vacation_time_journal, user: technician, amount: 20.0 }

    it 'should add yearly init record' do
      init_vacation_for_manager
      expect do
        VacationTime.new(manager).yearly
      end.to change TimeJournal, :count

      expect(TimeJournal.last).to be_initial
    end

    it 'sets balance to max of two years of allowed vacation time' do
      init_vacation_for_manager
      VacationTime.new(manager).yearly

      expect(manager.reload.remaining_vacation_time).to eql 80.0
    end

    it 'roll over unused vacation time from last year' do
      init_vacation_for_technician
      VacationTime.new(technician).yearly

      expect(technician.reload.remaining_vacation_time).to eql 56.0
    end
  end
end
