require 'rails_helper'

describe Notification do
  let(:redis) { Redis.new }

  describe 'create' do
    it 'should increment notification count' do
      Notification.create
      expect(redis.get('notifications_count')).to eq '1'
    end
  end

  describe 'reset' do
    it 'should reset counter to zero' do
      Notification.reset
      expect(redis.get('notifications_count')).to eq '0'
    end
  end

  describe 'count' do
    it 'should return notification count' do
      3.times { Notification.create }
      expect(Notification.count).to eq 3
    end
  end
end
