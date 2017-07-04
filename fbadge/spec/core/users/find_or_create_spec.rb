require 'rails_helper'

describe Users::FindOrCreate do
  context 'should return user and return true presence status' do
    specify 'if user exists' do
      user = create(:user)
      result, status = Users::FindOrCreate.new(user.email, user.name, user.surname).call
      expect(result).to eq(user)
      expect(status).to eq(true)
    end
  end

  context 'should create user and false presence status' do
    specify 'if user not exists' do
      ActionMailer::Base.deliveries = []
      email = 'johndoe@example.com'
      result, status = Users::FindOrCreate.new(email, 'John', 'Doe').call
      expect(result.email).to eq(email)
      expect(status).to eq(false)
      expect(ActionMailer::Base.deliveries.count).to eq(1)
    end
  end
end
