require 'rails_helper'

describe Monitorings::Uptime do
  let(:domain) { create :domain }

  context 'uptime' do
    before do
      @monitoring = create :monitoring, domain: domain, monitoring_type: :uptime
    end

    specify 'success check uptime' do
      allow_any_instance_of(Monitorings::Uptime).to receive(:find_result).and_return(
        http_code: 200, status: :success
      )

      expect(domain.uptime_status).to eq 'uptime_unknown'
      expect(History.count).to eq 0
      expect(@monitoring.last_status_changed_at).to be_nil

      Monitorings::Uptime.new(@monitoring).call

      expect(History.count).to eq 1
      expect(domain.reload.uptime_status).to eq('success')
      @monitoring.reload
      expect(@monitoring.last_status).to eq 'success'
      expect(@monitoring.consecutive_errors).to eq 0
      expect(@monitoring.last_status_changed_at.strftime('%Y-%d-%m %H:%M')).to(
        eq(Time.zone.now.strftime('%Y-%d-%m %H:%M'))
      )
    end

    specify 'domain is unavailable' do
      allow_any_instance_of(Monitorings::Uptime).to receive(:find_result).and_return(
        http_code: 404, status: :failure
      )

      expect(domain.uptime_status).to eq 'uptime_unknown'
      expect(History.count).to eq 0
      expect(@monitoring.last_status_changed_at).to be_nil

      Monitorings::Uptime.new(@monitoring).call

      expect(History.count).to eq 1
      expect(domain.reload.uptime_status).to eq('unavailable')
      @monitoring.reload
      expect(@monitoring.last_status).to eq 'failure'
      expect(@monitoring.consecutive_errors).to eq 1
      expect(@monitoring.last_status_changed_at.strftime('%Y-%d-%m %H:%M')).to(
        eq(Time.zone.now.strftime('%Y-%d-%m %H:%M'))
      )
    end

    specify 'error check uptime' do
      allow_any_instance_of(Monitorings::Uptime).to receive(:find_result).and_return(
        error_message: 'Invalid domain', status: :error
      )

      expect(domain.uptime_status).to eq 'uptime_unknown'
      expect(History.count).to eq 0
      expect(@monitoring.last_status_changed_at).to be_nil

      Monitorings::Uptime.new(@monitoring).call

      expect(History.count).to eq 1
      expect(domain.reload.uptime_status).to eq('error')
      @monitoring.reload
      expect(@monitoring.last_status).to eq 'error'
      expect(@monitoring.last_error).to eq 'Invalid domain'
      expect(@monitoring.consecutive_errors).to eq 1

      current_datetime = Time.zone.now.strftime('%Y-%d-%m %H:%M')
      expect(@monitoring.last_status_changed_at.strftime('%Y-%d-%m %H:%M')).to(
        eq(current_datetime)
      )

      allow_any_instance_of(Monitorings::Uptime).to receive(:find_result).and_return(
        error_message: 'Invalid domain', status: :error
      )

      Monitorings::Uptime.new(@monitoring).call

      expect(domain.reload.uptime_status).to eq('error')
      expect(History.count).to eq 2
      @monitoring.reload
      expect(@monitoring.last_status).to eq 'error'
      expect(@monitoring.consecutive_errors).to eq 2
      expect(@monitoring.last_status_changed_at.strftime('%Y-%d-%m %H:%M')).to(
        eq(current_datetime)
      )
    end

    specify 'last_status_changed_at changed only after change status' do
      allow_any_instance_of(Monitorings::Uptime).to receive(:find_result).and_return(
        error_message: 'Invalid domain', status: :error
      )

      expect(@monitoring.last_status_changed_at).to be_nil

      Monitorings::Uptime.new(@monitoring).call

      @monitoring.reload
      current_datetime = Time.zone.now.strftime('%Y-%d-%m %H:%M')
      expect(@monitoring.last_status_changed_at.strftime('%Y-%d-%m %H:%M')).to(
        eq(current_datetime)
      )

      allow_any_instance_of(Monitorings::Uptime).to receive(:find_result).and_return(
        error_message: 'Invalid domain', status: :error
      )

      Monitorings::Uptime.new(@monitoring).call

      allow_any_instance_of(Monitorings::Uptime).to receive(:find_result).and_return(
        http_code: 200, status: :success
      )

      Monitorings::Uptime.new(@monitoring).call

      @monitoring.reload
      expect(@monitoring.last_status_changed_at.strftime('%Y-%d-%m %H:%M')).to(
        eq(Time.zone.now.strftime('%Y-%d-%m %H:%M'))
      )
    end

    specify 'check for inactive domain' do
      domain.update!(status: :inactive)

      expect(domain.uptime_status).to eq 'uptime_unknown'
      expect(History.count).to eq 0
      expect(@monitoring.last_status_changed_at).to be_nil

      Monitorings::Uptime.new(@monitoring).call

      domain.reload
      @monitoring.reload

      expect(domain.uptime_status).to eq 'uptime_unknown'
      expect(History.count).to eq 0
      expect(@monitoring.last_status_changed_at).to be_nil
    end
  end
end
