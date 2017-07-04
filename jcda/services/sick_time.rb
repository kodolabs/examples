class SickTime < SickAndVacationTimeBase
  def init
    SickTimeJournal.create(
      user: user,
      period_start: period_start,
      period_end: period_end,
      amount: DEFAULT_AMOUNT,
      source: :initial,
    )
  end

  def auto
    SickTimeJournal.create(
      user: user,
      period_start: period_start,
      period_end: period_end,
      amount: calculate_amount,
      source: :auto,
    )
  end

  def use(request)
    SickTimeJournal.create(
      user: user,
      period_start: request.date,
      period_end: request.date,
      amount: -request.amount,
      source: :use,
      reason: request.details,
    )
  end

  def yearly
    SickTimeJournal.create!(
      user: user,
      source: :initial,
      period_start: period_start,
      period_end: period_end,
      amount: carryover_amount
    )
  end

  private

  def prev_period
    @prev_period ||= user.last_auto_sick_time_journal
  end

  def calculate_amount
    user.hourly? ? hourly : salaried
  end

  def carryover_amount
    last_initial = user.sick_time_journals.initial.ordered.first
    total = user.sick_time_journals.where('period_end >= ?', last_initial.period_end).sum(:amount)
    [40, total].min
  end

  def hourly
    uncounted_time_logs = user.time_logs
      .clock_out_between(prev_period.period_end, period_end)
    (uncounted_time_logs.map(&:total).reduce(&:+) || 0) * 1.0/40
  end

  def salaried
    (period_end - prev_period.period_end) * 1.0/(168*60*60)
  end
end
