require 'rails_helper'

describe TaskDecorator do
  let(:user_1) { create :user }
  let(:user_2) { create :user }
  let(:task) { create :task, created_by: user_1, assigned_to: user_2 }

  it '#flag_tag' do
    task.flag = false
    expect(task.decorate.flag_tag).to_not include('flag-link--active')

    task.flag = true
    expect(task.decorate.flag_tag).to include('flag-link--active')
  end

  it '#type_sym' do
    task.task_type = :general
    expect(task.decorate.type_sym).to eq 'G'

    task.task_type = :investigation
    expect(task.decorate.type_sym).to eq 'RI'
  end

  it '#created_by_name' do
    expect(task.decorate.created_by_name).to eq user_1.decorate&.safe_name
  end

  it '#assigned_to_name' do
    expect(task.decorate.assigned_to_name).to eq user_2.decorate&.safe_name
  end

  it '#format_due_date' do
    date = DateTime.now.utc
    task.due_date = date
    expect(task.decorate.format_due_date).to eq date.to_date.strftime(I18n.t('time.formats.site.date_full'))

    date = 1.day.ago.utc
    task.due_date = date
    expect(task.decorate.format_due_date).to include(date.to_date.strftime(I18n.t('time.formats.site.date_full')))
    expect(task.decorate.format_due_date).to include('rt-table__icon')
  end

  it '#disable_field?' do
    expect(task.decorate.disable_field?('assigned_to_id')).to be_falsy
  end

  it '#show_field?' do
    expect(task.decorate.show_field?('assigned_to_id')).to be_truthy
  end

  it '#formatted_description' do
    task.description = nil
    expect(task.decorate.formatted_description).to eq ''
    task.description = "123\n123\n123"
    expect(task.decorate.formatted_description).to eq '123<br/>123<br/>123'
  end
end
