require 'rails_helper'

describe Monitorings::Whois do
  let(:domain) { create :domain }
  context 'whois' do
    before do
      @monitoring = create :monitoring, domain: domain, monitoring_type: :whois
    end

    specify 'success check expires' do
      allow_any_instance_of(Monitorings::Whois).to receive(:find_result).and_return(
        expires_at: Time.zone.today + 1.year, status: :success
      )

      expect(domain.expires_at).to be_nil
      expect(domain.expiration_status).to eq 'expiration_unknown'
      expect(History.count).to eq 0
      expect(@monitoring.last_status_changed_at).to be_nil

      Monitorings::Whois.new(@monitoring).call

      expect(History.count).to eq 1
      expect(domain.reload.expires_at).to eq(Time.zone.today + 1.year)
      expect(domain.reload.expiration_status).to eq 'expiration_ok'
      @monitoring.reload
      expect(@monitoring.last_status).to eq 'success'
      expect(@monitoring.consecutive_errors).to eq 0
      expect(@monitoring.last_status_changed_at.strftime('%Y-%d-%m %H:%M')).to(
        eq(Time.zone.now.strftime('%Y-%d-%m %H:%M'))
      )
    end

    specify 'empty check expires' do
      allow_any_instance_of(Monitorings::Whois).to receive(:find_result).and_return(status: :empty)

      expect(domain.expires_at).to be_nil
      expect(domain.expiration_status).to eq 'expiration_unknown'
      expect(History.count).to eq 0
      expect(@monitoring.last_status_changed_at).to be_nil

      Monitorings::Whois.new(@monitoring).call

      expect(History.count).to eq 1
      expect(domain.reload.expires_at).to be_nil
      expect(domain.reload.expiration_status).to eq 'expiration_empty'
      @monitoring.reload
      expect(@monitoring.last_status).to eq 'empty'
      expect(@monitoring.last_error).to be_nil
      expect(@monitoring.consecutive_errors).to eq 1
      expect(@monitoring.last_status_changed_at.strftime('%Y-%d-%m %H:%M')).to(
        eq(Time.zone.now.strftime('%Y-%d-%m %H:%M'))
      )
    end

    specify 'error check expires' do
      allow_any_instance_of(Monitorings::Whois).to receive(:find_result).and_return(
        error_message: 'Invalid', status: :error
      )

      expect(domain.expires_at).to be_nil
      expect(domain.expiration_status).to eq 'expiration_unknown'
      expect(History.count).to eq 0
      expect(@monitoring.last_status_changed_at).to be_nil

      Monitorings::Whois.new(@monitoring).call

      expect(History.count).to eq 1
      expect(domain.reload.expires_at).to be_nil
      expect(domain.reload.expiration_status).to eq 'expiration_empty'
      @monitoring.reload
      expect(@monitoring.last_status).to eq 'error'
      expect(@monitoring.last_error).to eq 'Invalid'
      expect(@monitoring.consecutive_errors).to eq 1
      expect(@monitoring.last_status_changed_at.strftime('%Y-%d-%m %H:%M')).to(
        eq(Time.zone.now.strftime('%Y-%d-%m %H:%M'))
      )
    end

    specify 'error check expires - expiration_status is manual' do
      allow_any_instance_of(Monitorings::Whois).to receive(:find_result).and_return(
        error_message: 'Invalid', status: :error
      )

      domain.update!(
        expiration_status: :manual,
        expires_at: Time.zone.today + 2.years
      )

      expect(domain.expires_at).to eq(Time.zone.today + 2.years)
      expect(domain.expiration_status).to eq 'manual'
      expect(History.count).to eq 0
      expect(@monitoring.last_status_changed_at).to be_nil

      Monitorings::Whois.new(@monitoring).call

      expect(History.count).to eq 1
      expect(domain.reload.expires_at).to eq(Time.zone.today + 2.years)
      expect(domain.reload.expiration_status).to eq 'manual'

      @monitoring.reload
      expect(@monitoring.last_status).to eq 'error'
      expect(@monitoring.last_error).to eq 'Invalid'
      expect(@monitoring.consecutive_errors).to eq 1
      expect(@monitoring.last_status_changed_at.strftime('%Y-%d-%m %H:%M')).to(
        eq(Time.zone.now.strftime('%Y-%d-%m %H:%M'))
      )
    end

    specify 'success check expires - expiration_status is manual' do
      allow_any_instance_of(Monitorings::Whois).to receive(:find_result).and_return(
        expires_at: Time.zone.today + 1.year, status: :success
      )

      domain.update!(
        expiration_status: :manual,
        expires_at: Time.zone.today + 2.years
      )

      expect(domain.expires_at).to eq(Time.zone.today + 2.years)
      expect(domain.expiration_status).to eq 'manual'
      expect(History.count).to eq 0
      expect(@monitoring.last_status_changed_at).to be_nil

      Monitorings::Whois.new(@monitoring).call

      expect(History.count).to eq 1
      expect(domain.reload.expires_at).to eq(Time.zone.today + 1.year)
      expect(domain.reload.expiration_status).to eq 'expiration_ok'

      @monitoring.reload
      expect(@monitoring.last_status).to eq 'success'
      expect(@monitoring.last_error).to be_nil
      expect(@monitoring.consecutive_errors).to eq 0
      expect(@monitoring.last_status_changed_at.strftime('%Y-%d-%m %H:%M')).to(
        eq(Time.zone.now.strftime('%Y-%d-%m %H:%M'))
      )
    end

    specify 'check whois for inactive domain' do
      domain.update!(
        status: :inactive,
        expires_at: Time.zone.today + 1.year,
        expiration_status: :expiration_ok
      )

      allow_any_instance_of(Monitorings::Whois).to receive(:find_result).and_return(
        expires_at: Time.zone.today + 2.years, status: :success
      )

      expect(domain.expires_at).to eq(Time.zone.today + 1.year)
      expect(domain.expiration_status).to eq 'expiration_ok'

      Monitorings::Whois.new(@monitoring).call

      expect(domain.reload.expires_at).to eq(Time.zone.today + 1.year)
      expect(domain.reload.expiration_status).to eq 'expiration_ok'
    end
  end
end
