require 'rails_helper'

feature 'Registration' do
  specify 'user should be redirected to simulator when registration visited' do
    visit 'registration'
    expect(current_path).to eql(simulator_path)
  end
end
