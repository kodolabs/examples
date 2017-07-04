require 'rails_helper'

describe Professions::Destroy do
  context 'success' do
    let(:form) { Professions::Form }
    let(:command) { Professions::Destroy }
    specify 'destroy' do
      p = create(:profession)
      expect { command.new(p).call }.to change(Profession, :count).by(-1)
    end
  end
end
