require 'rails_helper'

describe Professions::Form do
  let(:form) { Professions::Form }
  context 'validation' do
    context 'unique title' do
      specify 'success' do
        f = form.new(title: 'abc')
        expect(f.valid?).to be_truthy
      end
      specify 'fail' do
        create(:profession, title: 'abc')
        f = form.new(title: 'abc')
        expect(f.valid?).to be_falsey
      end
    end
  end
end
