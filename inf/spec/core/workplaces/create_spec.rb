require 'rails_helper'

describe Workplaces::Create do
  context 'success' do
    let(:form) { Workplaces::Form }
    let(:command) { Workplaces::Create }
    specify 'create' do
      p = { 'form' => { title: 'test' } }
      f = form.from_params(p)
      expect { command.new(f).call }.to change(Workplace, :count).by(1)
    end
  end
end
