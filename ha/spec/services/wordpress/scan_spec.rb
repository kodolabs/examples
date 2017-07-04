require 'rails_helper'

describe Wordpress::Scan do
  let!(:host) { create :host }

  describe 'scan host' do
    context 'domain with www' do
      it 'host should be use www' do
        allow_any_instance_of(Mechanize).to receive(:get).and_return(
          Mechanize::Page.new
        )
        allow_any_instance_of(Mechanize::Page).to receive(:uri).and_return(
          URI::HTTP.build(host: 'www.google.com')
        )
        RestClient.stub(:get) { '{}' }

        expect(host.use_www).to eq false

        Wordpress::Scan.new(host).call

        host.reload

        expect(host.use_www).to eq true
      end
    end
  end

  context 'domain without www' do
    it 'host did not use www' do
      allow_any_instance_of(Mechanize).to receive(:get).and_return(
        Mechanize::Page.new
      )
      allow_any_instance_of(Mechanize::Page).to receive(:uri).and_return(
        URI::HTTP.build(host: 'google.com')
      )

      expect(host.use_www).to eq false

      Wordpress::Scan.new(host).call

      host.reload

      expect(host.use_www).to eq false
    end
  end
end
