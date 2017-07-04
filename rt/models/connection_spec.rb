require 'rails_helper'

RSpec.describe Connection, type: :model do
  let(:source) { create :source }
  let(:connection) { create :connection, source: source }

  describe 'FactoryGirl' do
    it 'work and valid' do
      expect(connection).to be_valid
    end
  end

  describe 'Validations' do
    it { expect(subject).to validate_presence_of(:location_id) }
    it { expect(subject).to validate_presence_of(:source_id) }
    it { expect(subject).to validate_presence_of(:reviews_url) }
    it { expect(subject).to validate_uniqueness_of(:source_id).scoped_to(:location_id) }
    it 'validate reviews_url by source url' do
      connection.reviews_url = 'http://www.other-domain.com'
      expect(connection.valid?).to be_falsy
    end
  end

  context 'Relationships' do
    it { expect(subject).to belong_to(:location) }
    it { expect(subject).to belong_to(:source) }
  end

  it 'should create connection with valid reviews_url' do
    source = create(:source, website: 'productreview.com.au')
    connection = build(:connection, reviews_url: 'http://www.productreview.com.au/metricon.html', source: source)
    expect(connection.valid?).to be true

    connection.reviews_url = 'http://productreview.com.au/metricon.html'
    expect(connection.valid?).to be true
  end

  context 'different national domains' do
    it 'should create connection with valid reviews_url for different national domains' do
      source = create(:source, website: 'google.com.au')
      connection = build(:connection, reviews_url: 'http://www.google.com.ua/metricon.html', source: source)
      expect(connection.valid?).to be true

      connection.reviews_url = 'http://google.com.ua/metricon.html'
      expect(connection.valid?).to be true
    end
    it 'work with co.uk domains' do
      source = create(:source, website: 'google.com.au')
      connection = build(:connection, reviews_url: 'http://www.google.co.uk/metricon.html', source: source)

      expect(connection.valid?).to be true

      connection.reviews_url = 'http://google.co.uk/metricon.html'
      expect(connection.valid?).to be true
    end
  end

  it '#delete_watch' do
    expect(Harvester).to receive(:unwatch)
    connection.destroy
  end
end
