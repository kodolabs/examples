class HistoriesCleanerWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { daily }

  HISTORY_INTERVAL = 1.year
  DEMOGRAPHICS_INTERVAL = 1.week

  def perform
    History.where('date < ?', interval_for('history')).delete_all
    Demographic.where('date < ?', interval_for('demographics')).delete_all
  end

  private

  def interval_for(column)
    interval = column == 'history' ? HISTORY_INTERVAL : DEMOGRAPHICS_INTERVAL

    Time.current.utc.beginning_of_day - interval
  end
end
