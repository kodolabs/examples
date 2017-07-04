require 'rails_helper'

describe RssDomains::Form do
  context 'validation' do
    let(:form) { RssDomains::Form }
    context 'title' do
      specify 'domain' do
        f = form.new(title: 'esquire.com/123')
        expect(f.valid?).to be_truthy
        expect(f.model_attributes[:host]).to eq 'esquire.com'
        expect(f.model_attributes[:title]).to eq 'esquire.com/123'
      end

      specify 'with http' do
        f = form.new(title: 'http://esquire.com/123')
        expect(f.valid?).to be_truthy
        expect(f.model_attributes[:host]).to eq 'esquire.com'
        expect(f.model_attributes[:title]).to eq 'http://esquire.com/123'
      end

      specify 'with wwww' do
        f = form.new(title: 'http://www.esquire.com/123')
        expect(f.valid?).to be_truthy
        expect(f.model_attributes[:host]).to eq 'esquire.com'
        expect(f.model_attributes[:title]).to eq 'http://www.esquire.com/123'
      end

      specify 'uniqueness' do
        create(:rss_domain, title: 'mail.com', host: 'mail.com')
        f = form.new(title: 'http://www.mail.com')
        expect(f.valid?).to be_falsey
      end
    end
  end
end
