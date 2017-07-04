require 'rails_helper'

describe Professions::Update do
  context 'success' do
    let(:form) { Professions::Form }
    let(:command) { Professions::Update }
    specify 'update' do
      p = create(:profession, title: 'abc', is_active: false)
      f = form.new(title: 'cba', is_active: true, id: p.id)
      expect { command.new(f).call }.to change(Profession, :count).by(0)
      p.reload
      expect(p.title).to eq 'cba'
      expect(p.is_active).to be_truthy
    end
  end
end
