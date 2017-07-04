require 'rails_helper'

describe Profiles::FindOrCreate do
  let!(:email) { FFaker::Internet.email }
  let!(:user) { create :user, :organiser, email: email }
  let!(:event) { create :event, :active, creator: user }
  let!(:name) { FFaker::Name.first_name }
  let!(:surname) { FFaker::Name.last_name }
  let!(:company) { FFaker::Company.name }
  let!(:job_title) { FFaker::Job.title }

  before(:each) do
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end

  after(:each) do
    ActionMailer::Base.deliveries.clear
  end

  context 'should return nil' do
    specify 'if email blank' do
      email = nil
      Profiles::FindOrCreate.new(email, name, surname, company, job_title, event).call
      expect(Profile.count).to eq(1)
      expect(ActionMailer::Base.deliveries.count).to eq(0)
    end
  end

  context 'should create new profile and return it' do
    specify 'if exists' do
      expect(Profile.count).to eq(0)
      result = Profiles::FindOrCreate.new(email, name, surname, company, job_title, event).call
      expect(Profile.count).to eq(1)
      expect(result.name).to eq(name)
      expect(ActionMailer::Base.deliveries.count).to eq(1)
    end
  end

  context 'should create and return profile' do
    specify 'if not exists' do
      expect(Profile.count).to eq(0)
      result = Profiles::FindOrCreate.new(email, name, surname, company, job_title, event).call
      expect(Profile.count).to eq(1)
      expect(result.name).to eq(name)
      expect(ActionMailer::Base.deliveries.count).to eq(1)
    end
  end
end
