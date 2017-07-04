require 'rails_helper'

RSpec.describe TimeLog, type: :model do
  let(:user) { create :user }
  let(:location) { create :location }
  before { create :payroll }

  describe '.clock_in' do
    it 'creates new time log for received user/location' do
      time_now = Time.now
      Timecop.freeze(time_now) do
        time_log = TimeLog.clock_in user, location

        expect(time_log.user).to be_eql user
        expect(time_log.location).to be_eql location
        expect(time_log.clock_in).to be_eql time_now
      end
    end

    it 'fails if user has opened time log' do
      create :time_log, :opened, user: user

      time_now = Time.now
      Timecop.freeze(time_now) do
        time_log = TimeLog.clock_in user, location

        expect(time_log.errors[:clock_in]).to be_eql ['You are not clocked-out.']
      end
    end
  end

  describe '.clock_out' do
    it 'update time log for received user wich time now as clocked-out time' do
      TimeLog.clock_in user, location

      time_now = Time.now
      Timecop.freeze(time_now) do
        time_log = TimeLog.clock_out user

        expect(time_log.user).to be_eql user
        expect(time_log.clock_out).to be_eql time_now
      end
    end

    it 'fails if user has no opened time log' do
      time_now = Time.now
      Timecop.freeze(time_now) do
        time_log = TimeLog.clock_out user

        expect(time_log.errors[:clock_out]).to be_eql ['You are not clocked-in.']
      end
    end
  end

  describe 'before_save' do
    context 'check lateness' do
      let!(:time_log) { create :time_log, clock_in: 3.hours.ago, expected_time: 4.hours.ago }

      it 'updates late_by if necessary' do
        expect do
          time_log.update(clock_in: time_log.clock_in - 52.minutes)
        end.to change { time_log.reload.late_by }.to(8.minute)

        expect do
          time_log.update(clock_in: time_log.clock_in - 1.hour)
        end.to change { time_log.reload.late_by }.to(nil)
      end
    end

    context 'sets regular, overtime and total hours' do
      context 'single time_log' do
        let!(:time_now) { Time.now }

        specify 'without overtime' do
          Timecop.freeze(time_now) do
            time_log = create :time_log, clock_in: 1.hours.ago

            time_log.update clock_out: time_now

            expect(time_log.regular).to eq 1.0
            expect(time_log.overtime).to eq 0.0
            expect(time_log.total).to eq 1.0
          end
        end

        specify 'with overtime' do
          Timecop.freeze(time_now) do
            time_log = create :time_log, clock_in: 41.hours.ago

            time_log.update clock_out: time_now

            expect(time_log.total).to eq 41.0
            expect(time_log.regular).to eq 40.0
            expect(time_log.overtime).to eq 1.0
          end
        end
      end

      context 'more than one time_log in week' do
        let!(:time_now) { Time.now.end_of_week(:sunday) }

        it 'first without overtime, second with overtime' do
          Timecop.freeze(time_now) do
            create :time_log, clock_in: 42.hours.ago, clock_out: 22.hours.ago, user: user
            time_log = create :time_log, clock_in: 21.hours.ago, user: user

            time_log.update clock_out: time_now

            expect(time_log.total).to eq 21.0
            expect(time_log.regular).to eq 20.0
            expect(time_log.overtime).to eq 1.0
          end
        end

        it 'first without overtime, second with overtime and regular, third without regular' do
          Timecop.freeze(time_now) do
            regular_time_log = create :time_log, clock_in: 44.hours.ago, clock_out: 24.hours.ago, user: user
            time_log_with_overtime_and_regular = create :time_log, clock_in: 23.hours.ago, clock_out: 2.hours.ago, user: user
            time_log_without_regular = create :time_log, clock_in: 1.hours.ago, user: user

            time_log_without_regular.update clock_out: time_now

            expect(time_log_with_overtime_and_regular.total).to eq 21.0
            expect(time_log_with_overtime_and_regular.regular).to eq 20.0
            expect(time_log_with_overtime_and_regular.overtime).to eq 1.0

            expect(time_log_without_regular.total).to eq 1.0
            expect(time_log_without_regular.regular).to eq 0.0
            expect(time_log_without_regular.overtime).to eq 1.0
          end
        end
      end

    end
  end

  describe 'after_save' do
    it 'update total/overtime/regular on editing clock-in/out' do
      Timecop.freeze(Time.now.end_of_week(:sunday)) do
        correct_time_log = create :time_log, user: user, clock_in: 80.hours.ago, clock_out: 60.hours.ago
        wrong_time_log = create :time_log, user: user, clock_in: 50.hours.ago, clock_out: 20.hours.ago

        expect do
          correct_time_log.update clock_out: correct_time_log.clock_out - 10.hours
        end.to change { wrong_time_log.reload.overtime }.from(10).to(0)
      end
    end
  end

  describe 'before_destroy' do
    let(:time_log) { create :time_log, user: user }
    let!(:request) { create :timelog_request, time_log: time_log }

    it 'deny pending associated requests' do
      expect do
        time_log.destroy
      end.to change { request.reload.status }.from('pending').to('denied')
      expect(request.decline_reason).to eql 'Clock-in deleted.'
    end
  end

  describe '#duration_in_hours' do
    describe 'closed time log' do
      it 'returns rounded difference between clock_in and clock_out' do
        expect(build(:time_log, :closed).duration_in_hours).to be 3.0
      end
    end

    describe 'opened time log' do
      subject { build(:time_log, :opened).duration_in_hours }
      it { should be nil }
    end
  end
end
