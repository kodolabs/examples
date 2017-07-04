require 'rails_helper'

describe Tags::Create do
  let(:service) { Tags::Create }

  context 'success' do
    specify 'downcase keyword' do
      form = Tags::TagForm.from_params(keyword: 'Kodo')
      expect { service.call(form) }.to change(Tag, :count).by(1)
      expect(Tag.last.keyword).to eq('kodo')
    end
  end

  context 'fail' do
    let(:tag) { create(:tag) }
    specify 'tag already exists' do
      form = Tags::TagForm.from_params(keyword: tag.keyword.upcase)
      expect { service.call(form) }.to change(Tag, :count).by(0)
      expect(form.valid?).to be_falsey
    end
  end
end
