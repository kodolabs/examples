require 'rails_helper'

describe News::Decorators::Sources::PubMed do
  context 'success' do
    let(:news) do
      build(:news, description: "BACKGROUND: a\n OBJECTIVE: b\n METHODS: c\n RESULTS: d\n CONCLUSIONS: e")
    end
    let(:decorator) { News::Decorators::Sources::PubMed }
    let(:desc) { 'BACKGROUND: a<br> OBJECTIVE: b<br> METHODS: c<br> RESULTS: d<br> CONCLUSIONS: e' }

    specify 'decorate' do
      decorated_item = decorator.new(news)
      expect(decorated_item.pubmed?).to be_truthy
      expect(decorated_item.description).to eq desc
      expect(decorated_item.short_description).to eq 'e'
    end
  end
end
