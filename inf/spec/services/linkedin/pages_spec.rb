require 'rails_helper'

describe Linkedin::Pages do
  context 'success' do
    let(:service) { Linkedin::Pages }
    let(:account) { create(:account, :linkedin) }

    specify 'index' do
      values = [{ 'id' => 'page_uid', handle: 'awesome' }]
      pages_body = { 'values' => values }
      image_body = { 'logoUrl' => 'http://linkedin.com/1.jpg' }
      stub_request(:get, 'https://api.linkedin.com/v1/companies?format=json&is-company-admin=true')
        .to_return(body: pages_body.to_json)
      stub_request(:get, 'https://api.linkedin.com/v1/companies/page_uid:(logo-url)?format=json')
        .to_return(body: image_body.to_json)
      response = service.new('aa').index
      valid_response = [{
        'id' => 'page_uid',
        'handle' => 'awesome',
        'picture' => 'http://linkedin.com/1.jpg'
      }]
      expect(response).to eq valid_response
    end

    context 'valid_token?' do
      specify 'auth error' do
        account
        stub_request(:get, 'https://api.linkedin.com/v1/companies?format=json&is-company-admin=true')
          .to_return(status: 401)

        expect(service.new(account.token).valid_token?).to be_falsey
      end
      specify 'no error' do
        account
        stub_request(:get, 'https://api.linkedin.com/v1/companies?format=json&is-company-admin=true')
          .to_return(status: 200)

        expect(service.new(account.token).valid_token?).to be_truthy
      end
    end
  end
end
