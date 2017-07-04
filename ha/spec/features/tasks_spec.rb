require 'rails_helper'

feature 'Tasks' do
  let!(:user) { create :user }
  let!(:domain) { create :domain }

  before { user_sign_in user }

  describe 'inspections' do
    before do
      @deindexed = create :task, :deindexed, status: :pending, taskable: domain, title: 'Deindexed Task'
      @deindexed2 = create :task, :deindexed, status: :in_progress, taskable: domain, title: 'Deindexed Task'
      @uptime = create :task, :uptime, status: :pending, taskable: domain, title: 'Uptime Task'
      @hacked = create :task, :hacked, status: :pending, taskable: domain, title: 'Hacked Task'
      visit tasks_path
    end

    it 'should display pending and in progress tasks' do
      expect(page).to have_content 'All - 4'
      expect(page).to have_content 'Deindexed Task'
      expect(page).to have_content 'Uptime Task'
      expect(page).to have_content 'Hacked Task'
    end

    it 'should filter by deindexed category' do
      find('.deindexed-tasks').click
      expect(page).to have_content 'Deindexed Task'
      expect(page).to have_no_content 'Uptime Task'
      expect(page).to have_no_content 'Hacked Task'
      expect(page).to have_link(nil, href: domain_path(@deindexed.taskable))
      expect(page).to have_content @deindexed.taskable.name
      expect(page).to have_content @deindexed.title
      expect(page).to have_link(nil, href: domain_path(@deindexed2.taskable))
      expect(page).to have_content @deindexed2.taskable.name
      expect(page).to have_content @deindexed2.title
    end

    it 'should filter by uptime category' do
      find('.uptime-tasks').click
      expect(page).to have_content 'Uptime Task'
      expect(page).to have_no_content 'Deindexed Task'
      expect(page).to have_no_content 'Hacked Task'
      expect(page).to have_link(nil, href: domain_path(@uptime.taskable))
      expect(page).to have_content @uptime.taskable.name
      expect(page).to have_content @uptime.title
    end

    it 'should filter by hacked category' do
      find('.hacked-tasks').click
      expect(page).to have_content 'Hacked Task'
      expect(page).to have_link(nil, href: domain_path(@hacked.taskable))
      expect(page).to have_content @hacked.taskable.name
      expect(page).to have_content @hacked.title
      expect(page).to have_no_content 'Uptime Task'
      expect(page).to have_no_content 'Deindexed Task'
    end
  end

  describe 'history' do
    before do
      @task = create :task, :payment, status: :done, taskable: domain, assigned_to: user.id, title: 'Payment'
      visit history_tasks_path
    end

    it 'should display tasks' do
      expect(page).to have_link(nil, href: domain_path(@task.taskable))
      expect(page).to have_content @task.title
      expect(page).to have_content @task.status
      expect(page).to have_content @task.user.name
    end
  end
end
