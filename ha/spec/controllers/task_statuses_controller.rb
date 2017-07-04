require 'rails_helper'

describe TaskStatusesController, type: :controller do
  let!(:user) { create :user }
  let!(:task) { create :task, :pending, :deindexed }

  before { sign_in user }

  context 'status pending' do
    specify 'success' do
      params = { id: task.id }
      put :status_pending, params: params
      expect(response.status).to eq(200)
      body = JSON.parse(response.body)
      expect(body['counters']['history']).to eq 0
      expect(task.reload.status).to eq('pending')
    end
  end

  context 'status done' do
    specify 'success' do
      params = { id: task.id }
      put :status_done, params: params, xhr: true
      expect(response.status).to eq(200)
      body = JSON.parse(response.body)
      expect(body['counters']['all']).to eq 0
      expect(task.reload.status).to eq('done')
    end
  end

  context 'status ignore' do
    specify 'success' do
      params = { id: task.id }
      put :status_ignore, params: params, xhr: true
      expect(response.status).to eq(200)
      body = JSON.parse(response.body)
      expect(body['counters']['all']).to eq 0
      expect(task.reload.status).to eq('ignore')
    end
  end

  context 'status in_progress' do
    specify 'success' do
      params = { id: task.id }
      put :status_in_progress, params: params, xhr: true
      expect(response.status).to eq(200)
      body = JSON.parse(response.body)
      expect(body['in_progress']).to eq true
      expect(task.reload.status).to eq('in_progress')
    end
  end
end
