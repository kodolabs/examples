class CheckTokenWorker
  include Sidekiq::Worker

  def perform(account_id)
    CheckToken::Base.new(account_id).call
  end
end
