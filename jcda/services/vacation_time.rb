class VacationTime < SickAndVacationTimeBase
  DEFAULT_AMOUNT = 36

  def init
    VacationTimeJournal.create!(
      user: user,
      period_start: period_start,
      # TODO: I BELIEVE VACATION END DATE SHOULD BE END OF YEAR BUT IT CAUSES PROBLEMS WITH BALANCE CALCULATION
      period_end: period_end,
      amount: initial_amount,
      source: :initial
    )
  end

  def use(request)
    VacationTimeJournal.create!(
      user: user,
      period_start: request.date,
      period_end: request.date,
      amount: -request.amount,
      source: :use,
      reason: request.details
    )
  end

  def yearly
    VacationTimeJournal.create!(
      user: user,
      period_start: yearly_period_start,
      period_end: yearly_period_end,
      amount: year_amount,
      source: :initial
    )
  end

  private

  def yearly_period_start
    Time.current.beginning_of_year
  end

  def yearly_period_end
    Time.current.beginning_of_year
  end

  def prev_period
    nil
  end

  def initial_amount
    year_size = Date.new(Date.today.year, 12, 31).yday
    days_to_year_end = year_size - Date.today.yday + 1 # include current day
    (days_to_year_end.to_f / year_size) * yearly_user_vacation
  end

  def year_amount
    last_initial = user.vacation_time_journals.initial.ordered.first
    total = user.vacation_time_journals.where('period_end >= ?', last_initial.period_end).sum(:amount)
    [2 * yearly_user_vacation, total + yearly_user_vacation].min
  end

  def yearly_user_vacation
    user.vacation.to_i > 0 ? user.vacation.to_i : DEFAULT_AMOUNT
  end
end
