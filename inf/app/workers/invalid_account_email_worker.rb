class InvalidAccountEmailWorker
  include Sidekiq::Worker

  def perform(customer_id)
    InvalidAccountMailer.notification(customer_id).deliver_later
  end
end
