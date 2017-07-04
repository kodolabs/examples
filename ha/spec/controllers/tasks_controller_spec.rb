require 'rails_helper'

describe TasksController, type: :controller do
  let!(:user) { create :user }
  let!(:task) { create :task, :pending, :deindexed }

  before { sign_in user }

  context 'assign user' do
    specify 'success' do
      params = { user_id: user.id, id: task.id }
      put :assign, params: params, xhr: true
      expect(response.status).to eq(200)
      expect(task.reload.user).to eq(user)
    end
  end

  context 'remove user association' do
    specify 'success' do
      task.update(user: user)
      params = { user_id: '', id: task.id }
      put :assign, params: params, xhr: true
      expect(response.status).to eq(200)
      expect(task.reload.user).to eq(nil)
    end
  end
end
