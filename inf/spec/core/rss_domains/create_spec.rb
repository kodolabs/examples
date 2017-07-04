require 'rails_helper'

describe RssDomains::Create do
  let(:command) { RssDomains::Create }

  context 'success' do
    let(:form) { RssDomains::Form.new(title: 'http://www.esquire.com/123.html') }
    specify 'create' do
      command.new(form).call
      expect(RssDomain.last.host).to eq('esquire.com')
    end
  end
end
