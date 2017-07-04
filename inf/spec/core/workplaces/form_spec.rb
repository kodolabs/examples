require 'rails_helper'

describe Workplaces::Form do
  context 'success' do
    let(:form) { Workplaces::Form }
    context 'validation' do
      context 'title uniq' do
        specify 'fail' do
          create(:workplace, title: 'Existing')
          p = { 'form' => { title: 'Existing' } }
          f = form.from_params(p)
          expect(f.valid?).to be_falsey
        end

        specify 'success' do
          p = { 'form' => { title: 'Not Existing' } }
          f = form.from_params(p)
          expect(f.valid?).to be_truthy
        end
      end
    end
  end
end
