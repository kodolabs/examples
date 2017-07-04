require 'rails_helper'

describe InvalidAccountEmailWorker do
  context 'success' do
    let(:worker) { InvalidAccountEmailWorker }
    let(:mailer) { InvalidAccountMailer }

    specify 'send email' do
      customer_id = rand(1..100)
      obj = double('mailer')
      allow(obj).to receive(:deliver_later)
      allow(mailer).to receive(:notification).and_return(obj)
      expect(mailer).to receive(:notification).once.with(customer_id)
      worker.new.perform(customer_id)
    end
  end
end
