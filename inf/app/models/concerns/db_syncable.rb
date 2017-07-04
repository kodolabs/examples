module DbSyncable
  extend ActiveSupport::Concern

  included do
    unless Rails.env == 'test'
      after_commit -> { sync_db(transaction_record_state(:new_record)) }
    end
  end

  private

  def sync_db(new_record)
    SyncDbService.new(self, new_record).call
  end
end
