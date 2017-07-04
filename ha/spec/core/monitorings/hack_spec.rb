require 'rails_helper'

describe Monitorings::Hack do
  let(:domain) { create :domain }

  def fake_response(body: '', url: 'http://example.com', method: 'get', code: 200)
    net_http_res = double('response', to_hash: {}, code: code)
    request = double(
      'request',
      url: url,
      uri: URI.parse(url),
      method: method,
      user: nil,
      password: nil,
      cookie_jar: HTTP::CookieJar.new,
      redirection_history: nil,
      args: { url: url, method: method }
    )
    RestClient::Response.create(body, net_http_res, request)
  end

  context 'hack' do
    before do
      @monitoring = create :monitoring, domain: domain, monitoring_type: :hack
    end

    specify 'not be checked for unavailable host' do
      domain.unavailable!

      expect(domain.hack_status).to eq 'hack_unknown'
      expect(History.count).to eq 0
      expect(@monitoring.last_status_changed_at).to be_nil

      Monitorings::Hack.new(@monitoring).call

      expect(History.count).to eq 0
      expect(domain.reload.hack_status).to eq('hack_unknown')
      @monitoring.reload
      expect(@monitoring.last_status).to eq 'empty'
      expect(Task.hacked.count).to eq 0
    end

    specify 'success check hack' do
      allow(RestClient).to receive(:get).and_return(fake_response(code: 200, body: FFaker::HTMLIpsum.body))

      expect(domain.hack_status).to eq 'hack_unknown'
      expect(History.count).to eq 0
      expect(@monitoring.last_status_changed_at).to be_nil

      Monitorings::Hack.new(@monitoring).call

      expect(History.count).to eq 1
      expect(domain.reload.hack_status).to eq('good')
      @monitoring.reload
      expect(@monitoring.last_status).to eq 'success'
      expect(@monitoring.consecutive_errors).to eq 0
      expect(@monitoring.last_status_changed_at.strftime('%Y-%d-%m %H:%M')).to(
        eq(Time.zone.now.strftime('%Y-%d-%m %H:%M'))
      )
      expect(Task.hacked.count).to eq 0
    end

    specify 'error - invalid http code' do
      allow(RestClient).to receive(:get).and_return(fake_response(code: 404))

      expect(domain.hack_status).to eq 'hack_unknown'
      expect(History.count).to eq 0
      expect(@monitoring.last_status_changed_at).to be_nil

      Monitorings::Hack.new(@monitoring).call

      expect(History.count).to eq 1
      expect(domain.reload.hack_status).to eq('hacked')
      @monitoring.reload
      expect(@monitoring.last_status).to eq 'error'
      expect(@monitoring.last_error).to eq I18n.t('notifications.invalid_http_code', code: 404)
      expect(@monitoring.consecutive_errors).to eq 1
      expect(@monitoring.last_status_changed_at.strftime('%Y-%d-%m %H:%M')).to(
        eq(Time.zone.now.strftime('%Y-%d-%m %H:%M'))
      )
    end

    specify 'error - invalid content length' do
      allow(RestClient).to receive(:get).and_return(fake_response(code: 200))

      expect(domain.hack_status).to eq 'hack_unknown'
      expect(History.count).to eq 0
      expect(@monitoring.last_status_changed_at).to be_nil

      Monitorings::Hack.new(@monitoring).call

      expect(History.count).to eq 1
      expect(domain.reload.hack_status).to eq('hacked')
      @monitoring.reload
      expect(@monitoring.last_status).to eq 'error'
      expect(@monitoring.last_error).to eq I18n.t(
        'notifications.invalid_content_length',
        size: 0
      )
      expect(@monitoring.consecutive_errors).to eq 1
      expect(@monitoring.last_status_changed_at.strftime('%Y-%d-%m %H:%M')).to(
        eq(Time.zone.now.strftime('%Y-%d-%m %H:%M'))
      )
    end

    specify 'error - not contain any html' do
      allow(RestClient).to receive(:get).and_return(
        fake_response(code: 200, body: FFaker::LoremFR.paragraph * 20)
      )

      expect(domain.hack_status).to eq 'hack_unknown'
      expect(History.count).to eq 0
      expect(@monitoring.last_status_changed_at).to be_nil

      Monitorings::Hack.new(@monitoring).call

      expect(History.count).to eq 1
      expect(domain.reload.hack_status).to eq('hacked')
      @monitoring.reload
      expect(@monitoring.last_status).to eq 'error'
      expect(@monitoring.last_error).to eq I18n.t('notifications.not_contain_any_html')
      expect(@monitoring.consecutive_errors).to eq 1
      expect(@monitoring.last_status_changed_at.strftime('%Y-%d-%m %H:%M')).to(
        eq(Time.zone.now.strftime('%Y-%d-%m %H:%M'))
      )
    end

    specify 'error - contains stop keyword' do
      keyword = Monitorings::Hack::STOP_KEYWORDS.first
      allow(RestClient).to receive(:get).and_return(
        fake_response(code: 200, body: "#{FFaker::HTMLIpsum.body} #{keyword}")
      )

      expect(domain.hack_status).to eq 'hack_unknown'
      expect(History.count).to eq 0
      expect(@monitoring.last_status_changed_at).to be_nil

      Monitorings::Hack.new(@monitoring).call

      expect(History.count).to eq 1
      expect(domain.reload.hack_status).to eq('hacked')
      @monitoring.reload
      expect(@monitoring.last_status).to eq 'error'
      expect(@monitoring.last_error).to eq I18n.t(
        'notifications.contain_stop_keyword',
        keyword: keyword
      )
      expect(@monitoring.consecutive_errors).to eq 1
      expect(@monitoring.last_status_changed_at.strftime('%Y-%d-%m %H:%M')).to(
        eq(Time.zone.now.strftime('%Y-%d-%m %H:%M'))
      )
    end
  end
end
