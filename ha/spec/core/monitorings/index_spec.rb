require 'rails_helper'

describe Monitorings::Index do
  let(:domain) { create :domain }

  context 'index' do
    before do
      @monitoring = create :monitoring, domain: domain, monitoring_type: :indexed
    end

    specify 'success check' do
      allow_any_instance_of(Monitorings::Index).to receive(:find_result).and_return(
        status: :success, index_status: :indexed, pages_count: 100
      )
      Monitorings::Index.any_instance.stub(:response).and_return({})

      expect(domain.index_status).to eq 'index_unknown'
      expect(History.count).to eq 0
      expect(@monitoring.last_status_changed_at).to be_nil

      Monitorings::Index.new(@monitoring).call

      expect(History.count).to eq 1
      expect(domain.reload.index_status).to eq('indexed')
      expect(domain.reload.index_pages).to eq 100
      @monitoring.reload
      expect(@monitoring.last_status).to eq 'success'
      expect(@monitoring.consecutive_errors).to eq 0
      expect(@monitoring.last_status_changed_at.strftime('%Y-%d-%m %H:%M')).to(
        eq(Time.zone.now.strftime('%Y-%d-%m %H:%M'))
      )
      expect(Alert.count).to eq 0
      expect(Task.count).to eq 0
    end

    specify 'error check - 0 pages' do
      allow_any_instance_of(Monitorings::Index).to receive(:find_result).and_return(
        status: :success, index_status: :not_indexed, pages_count: 0
      )
      Monitorings::Index.any_instance.stub(:response).and_return({})
      expect(@monitoring.last_status_changed_at).to be_nil

      Monitorings::Index.new(@monitoring).call

      expect(domain.reload.index_status).to eq('not_indexed')
      expect(domain.reload.index_pages).to eq 0
      @monitoring.reload
      expect(@monitoring.last_status).to eq 'success'
      expect(@monitoring.consecutive_errors).to eq 0
      expect(@monitoring.last_status_changed_at.strftime('%Y-%d-%m %H:%M')).to(
        eq(Time.zone.now.strftime('%Y-%d-%m %H:%M'))
      )
      expect(Alert.count).to eq 1
      expect(Task.count).to eq 1
    end

    specify 'error check - parse error and indexation unknown' do
      allow_any_instance_of(Monitorings::Index).to receive(:find_result).and_return(
        status: :error, error_message: 'Invalid'
      )
      Monitorings::Index.any_instance.stub(:response).and_return(error_message: 'Invalid')
      expect(@monitoring.last_status_changed_at).to be_nil

      Monitorings::Index.new(@monitoring).call

      expect(History.count).to eq 1
      expect(domain.reload.index_status).to eq('index_unknown')
      expect(domain.reload.index_pages).to be_nil
      @monitoring.reload
      expect(@monitoring.last_status).to eq 'empty'
      expect(@monitoring.last_error).to be_nil
      expect(@monitoring.consecutive_errors).to be_nil
      expect(@monitoring.last_status_changed_at).to be_nil
      expect(Alert.count).to eq 0
      expect(Task.count).to eq 0
    end

    specify 'error check - domain alredy indexed and not updated after fail check' do
      allow_any_instance_of(Monitorings::Index).to receive(:find_result).and_return(
        status: :error, error_message: 'Invalid'
      )
      Monitorings::Index.any_instance.stub(:response).and_return(error_message: 'Invalid')

      domain.update(
        index_status: :indexed,
        index_pages: 1000
      )
      @monitoring.update(
        last_status: :success,
        last_error: nil,
        consecutive_errors: 0
      )
      expect(History.count).to eq 0
      expect(@monitoring.last_status_changed_at).to be_nil

      Monitorings::Index.new(@monitoring).call

      expect(History.count).to eq 1
      expect(domain.reload.index_status).to eq('indexed')
      expect(domain.reload.index_pages).to eq 1000
      @monitoring.reload
      expect(@monitoring.last_status).to eq 'success'
      expect(@monitoring.last_error).to be_nil
      expect(@monitoring.consecutive_errors).to eq 0
      expect(@monitoring.last_status_changed_at).to be_nil
      expect(Alert.count).to eq 0
      expect(Task.count).to eq 0
    end

    specify 'check for inactive domain' do
      domain.update!(status: :inactive)

      expect(domain.index_status).to eq 'index_unknown'
      expect(History.count).to eq 0
      expect(@monitoring.last_status_changed_at).to be_nil

      Monitorings::Index.new(@monitoring).call

      domain.reload
      @monitoring.reload

      expect(domain.index_status).to eq 'index_unknown'
      expect(History.count).to eq 0
      expect(@monitoring.last_status_changed_at).to be_nil
      expect(Alert.count).to eq 0
      expect(Task.count).to eq 0
    end

    specify 'last_status_changed_at should be changed' do
      allow_any_instance_of(Monitorings::Index).to receive(:find_result).and_return(
        status: :success, index_status: :indexed, pages_count: 100
      )
      Monitorings::Index.any_instance.stub(:response).and_return({})
      time = Time.zone.now - 1.day

      domain.update!(index_status: 'indexed')
      @monitoring.update!(last_status_changed_at: time)

      Monitorings::Index.new(@monitoring).call

      domain.reload
      @monitoring.reload

      expect(domain.index_status).to eq 'indexed'
      expect(@monitoring.last_status_changed_at.strftime('%Y-%d-%m %H:%M')).to eq(
        time.strftime('%Y-%d-%m %H:%M')
      )

      allow_any_instance_of(Monitorings::Index).to receive(:find_result).and_return(
        status: :success, index_status: :not_indexed, pages_count: 0
      )

      Monitorings::Index.new(@monitoring).call

      domain.reload
      @monitoring.reload

      expect(domain.index_status).to eq 'not_indexed'
      expect(@monitoring.last_status_changed_at.strftime('%Y-%d-%m %H:%M')).to eq(
        Time.zone.now.strftime('%Y-%d-%m %H:%M')
      )
      expect(Alert.count).to eq 1
      expect(Task.count).to eq 1
    end
  end
end
