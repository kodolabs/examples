require 'rails_helper'

describe Professions::Create do
  context 'success' do
    let(:form) { Professions::Form }
    let(:command) { Professions::Create }
    specify 'create' do
      f = form.new(title: 'abc', is_active: true)
      expect { command.new(f).call }.to change(Profession, :count).by(1)
    end
  end
end
