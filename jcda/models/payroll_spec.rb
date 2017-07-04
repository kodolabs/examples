require 'rails_helper'

RSpec.describe Payroll, type: :model do
  def days_to_start(number)
    Payroll::PERIODS_START_DAYS[number]
  end
  def days_to_end(number)
    # first period ended on second start day - 1
    number = number == :first ? :second : :first
    Payroll::PERIODS_START_DAYS[number] - 1
  end

  describe '#current' do
    it 'returns first opened payroll' do
      payroll = create :payroll, start_date: Time.now - 1.days, end_date: Time.now - 1.seconds
      create :payroll, start_date: Time.now, end_date: Time.now + 1.days

      expect(Payroll.current).to eql payroll
    end
  end

  describe '#calculate' do
    it 'assigns necessary data to payment from time_logs and user' do
      user = create :user
      location = create :location
      payroll = create :payroll,
        start_date: Time.new(2016, 1, days_to_start(:first), 0, 0, 0, "-06:00"),
        end_date:   Time.new(2016, 1, days_to_end(:first), 23, 59, 59, "-06:00")
      time_log = create :time_log, user: user,
        clock_in:   Time.new(2016, 1, 5, 9, 0, 0, "-06:00"),
        clock_out:  Time.new(2016, 1, 5, 19, 0, 0, "-06:00"),
        location:   location
      expect { payroll.calculate }.to change(Payment, :count).from(0).to(1)

      payment = Payment.first
      expect(payment.payroll).to be_eql payroll
      expect(payment.location).to be_eql location
      expect(payment.user).to be_eql user
      expect(payment.pay_type).to be_eql "hourly"
      expect(payment.pay_rate).to be_eql 75.00
    end

    context 'summaries' do
      let!(:user) { create :user }
      before do
        location = create :location
        @payroll = create :payroll,
          start_date: Time.new(2016, 1, days_to_start(:first), 0, 0, 0, "-06:00"),
          end_date:   Time.new(2016, 1, days_to_end(:first), 23, 59, 59, "-06:00")
        time_log_20_hours = create :time_log, user: user,
          clock_in:   Time.new(2016, 1, 5, 9, 0, 0, "-06:00"),
          clock_out:  Time.new(2016, 1, 6, 5, 0, 0, "-06:00"),
          location:   location
        time_log_30_hours = create :time_log, user: user,
          clock_in:   Time.new(2016, 1, 7, 9, 0, 0, "-06:00"),
          clock_out:  Time.new(2016, 1, 8, 15, 0, 0, "-06:00"),
          location:   location
      end

      specify 'for payment' do
        expect { @payroll.calculate }.to change(Payment, :count).from(0).to(1)

        payment = Payment.first
        expect(payment.regular_hours).to be_eql 40.00
        expect(payment.overtime_hours).to be_eql 10.00

        pay_rate = 75.00
        regular = 40.00
        overtime = 10.00
        bonus = 0
        base_pay = regular * pay_rate + overtime * (pay_rate * 1.5)
        expect(payment.base_pay).to be_eql base_pay
        expect(payment.bonus_pay).to be_eql bonus
        expect(payment.gross_pay).to be_eql base_pay + bonus
      end

      specify 'for payroll' do
        @payroll.calculate

        expect(@payroll.regular_hours).to be_eql 40.00
        expect(@payroll.overtime_hours).to be_eql 10.00

        pay_rate = 75.00
        regular = 40.00
        overtime = 10.00
        bonus = 0
        base_pay = regular * pay_rate + overtime * (pay_rate * 1.5)
        expect(@payroll.base_pay).to be_eql base_pay
        expect(@payroll.bonus_pay).to be_eql bonus
        expect(@payroll.gross_pay).to be_eql base_pay + bonus
      end

      context 'sick time in payment' do
        before do
          create :sick_time_journal, user: user
          create :sick_time_journal, amount: 8.0, source: :use, user: user, period_end: Date.new(2016, 1, days_to_start(:first) + 2)
          create :sick_time_journal, amount: 8.0, source: :use, user: user, period_end: Date.new(2016, 1, days_to_start(:first) - 2)

          another_user = create :user
          create :sick_time_journal, user: another_user
          create :sick_time_journal, amount: 8.0, source: :use, user: another_user, period_end: Date.new(2016, 1, days_to_start(:first) + 2)

          @payroll.calculate
        end

        it 'count sick hours as regular hours' do
          payment = Payment.first
          expect(payment.sick_hours).to be_eql 8.0
          expect(payment.base_pay).to be_eql 4725.0
        end
      end

      context 'vacation time in payment' do
        before do
          create :vacation_time_journal, user: user
          create :vacation_time_journal, amount: 8.0, source: :use, user: user, period_end: Date.new(2016, 1, days_to_start(:first) + 2)
          create :vacation_time_journal, amount: 8.0, source: :use, user: user, period_end: Date.new(2016, 1, days_to_start(:first) - 2)

          another_user = create :user
          create :vacation_time_journal, user: another_user
          create :vacation_time_journal, amount: 8.0, source: :use, user: another_user, period_end: Date.new(2016, 1, days_to_start(:first) + 2)

          @payroll.calculate
        end

        it 'count sick hours as regular hours' do
          payment = Payment.first
          expect(payment.vacation_hours).to be_eql 8.0
          expect(payment.base_pay).to be_eql 4725.0
        end
      end
    end

    it 'does not start for submitted payrolls' do
      payroll = create :payroll,
        start_date: Time.new(2016, 1, days_to_start(:first), 0, 0, 0, "-06:00"),
        end_date:   Time.new(2016, 1, days_to_end(:first), 23, 59, 59, "-06:00"),
        submitted: true
      expect(payroll.calculate).to be_nil
    end

    it 'removes self payments before calculation' do
      create :payment, payroll: create(:payroll)
      payroll = create :payroll, payments: [create(:payment)]
      expect { payroll.calculate }.to change(Payment, :count).from(2).to(1)
    end

    it 'does not fails if opened time_logs existed' do
      payroll = create :payroll, payments: [create(:payment)]
      create :time_log, clock_in: payroll.start_date + 2.days
      expect { payroll.calculate }.not_to raise_exception
    end

    it 'count sick time once per user' do
      user = create :user
      location = create :location
      another_location = create :location
      payroll = create :payroll,
        start_date: Time.new(2016, 1, days_to_start(:first), 0, 0, 0, "-06:00"),
        end_date:   Time.new(2016, 1, days_to_end(:first), 23, 59, 59, "-06:00")
      time_log = create :time_log, user: user,
        clock_in:   Time.new(2016, 1, 5, 9, 0, 0, "-06:00"),
        clock_out:  Time.new(2016, 1, 6, 5, 0, 0, "-06:00"),
        location:   location
      another_time_log = create :time_log, user: user,
        clock_in:   Time.new(2016, 1, 7, 9, 0, 0, "-06:00"),
        clock_out:  Time.new(2016, 1, 8, 15, 0, 0, "-06:00"),
        location:   another_location
      sick_time_journal = create :sick_time_journal, user: user, amount: 10.0,
        period_end: Time.new(2016, 1, 5, 9, 0, 0, "-06:00")
      sick_time_journal = create :sick_time_journal, user: user, amount: -8.0,
        period_end: Time.new(2016, 1, 7, 9, 0, 0, "-06:00"), source: :use

      payroll.calculate
      expect(payroll.reload.payments.first.sick_hours).to eql 8.0
      expect(payroll.reload.payments.second.sick_hours).to eql 0.0
    end

    xit 'recalculation'

    xit 'range checks(one time_log outside rage)'
  end

  describe '.create' do
    describe 'when payrolls exist in system' do
      describe 'should creates payroll with start date next to previous payroll end date' do
        context 'success if today is end_date' do
          it 'prev payroll from 5 to 18' do
            payroll = create :payroll, :range_from_5_to_19
            payroll.update! end_date: payroll.end_date - 1.days
            Timecop.freeze(Time.new(2016, 1, 19, 0, 0, 0, "-06:00")) do
              new_payroll = nil
              expect { new_payroll = Payroll.create }.to change(Payroll, :count).from(1).to(2)
              expect(new_payroll.start_date).to eql payroll.end_date + 1.seconds
              expect(new_payroll.end_date.to_s(:long)).to eql Time.new(2016, 1, days_to_end(:first), 23, 59, 59, "-06:00").to_s(:long)
            end
          end

          it 'prev payroll from 20 to 4' do
            create :payroll, :range_from_20_to_4
            Timecop.freeze(Time.new(2016, 2, 5, 0, 0, 0, "-06:00")) do
              new_payroll = nil
              expect { new_payroll = Payroll.create }.to change(Payroll, :count).from(1).to(2)
              expect(new_payroll.start_date).to eql Time.new(2016, 2, days_to_start(:first), 0, 0, 0, "-06:00")
              expect(new_payroll.end_date.to_s(:long)).to eql Time.new(2016, 2, days_to_end(:first), 23, 59, 59, "-06:00").to_s(:long)
            end
          end
        end

        it 'fails if today is not end_date' do
          payroll = create :payroll, :range_from_5_to_19
          Timecop.freeze(Time.new(2016, 1, 18, 0, 0, 0, "-06:00")) do
            new_payroll = nil
            expect { new_payroll = Payroll.create }.not_to change(Payroll, :count)
            expect(new_payroll.errors).to be_any
            expect(new_payroll.errors[:base]).to be_eql ["can be created only at first payroll day"]
          end
        end
      end
    end

    describe 'when no payrolls in system' do
      describe 'create new payroll with nearest start date in future' do
        specify 'if to day is in 2016.1.1..2016.1.4 then payroll range 2016.1.5..2016.1.20' do
          time_now = Time.local(2016, 1, 4)
          Timecop.freeze(time_now) do
            new_payroll = Payroll.create
            expect(new_payroll.start_date.to_s(:long)).to eql Time.new(2016, 1, days_to_start(:first), 0, 0, 0, "-06:00").to_s(:long)
            expect(new_payroll.end_date.to_s(:long)).to eql Time.new(2016, 1, days_to_end(:first), 23, 59, 59, "-06:00").to_s(:long)
          end
        end
      end

      specify 'if to day is in 2016.1.20..2016.2.4 then payroll range 2016.2.5..2016.2.20' do
        time_now = Time.local(2016, 1, 22)
        Timecop.freeze(time_now) do
          new_payroll = Payroll.create
          expect(new_payroll.start_date.to_s(:long)).to eql Time.new(2016, 2, days_to_start(:first), 0, 0, 0, "-06:00").to_s(:long)
          expect(new_payroll.end_date.to_s(:long)).to eql Time.new(2016, 2, days_to_end(:first), 23, 59, 59, "-06:00").to_s(:long)
        end
      end
    end
  end
end
