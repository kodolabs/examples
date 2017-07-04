require 'rails_helper'

describe Shares::Decorators::Base do
  context 'success' do
    let(:service) { Shares::Decorators::Articles::Facebook }
    specify 'convert decorated data to openstruct' do
      record = { a: 1, b: nil }
      allow_any_instance_of(Shares::Decorators::Articles::Base).to receive(:decorate) { record }
      res = service.new(record).call
      valid_res = OpenStruct.new(a: 1)
      expect(res).to eq(valid_res)
    end
  end
end
