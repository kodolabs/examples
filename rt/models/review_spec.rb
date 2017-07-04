require 'rails_helper'

RSpec.describe Review, type: :model do
  let(:review) { create :review }

  context 'FactoryGirl :review' do
    it 'work and valid' do
      expect(review).to be_valid
    end

    it 'set as new' do
      expect(review._unread?).to be_truthy
    end
  end

  context 'Relationships' do
    it { expect(subject).to belong_to(:location) }
    it { expect(subject).to belong_to(:source) }
    it { expect(subject).to have_one(:request_invitation) }
    it { expect(subject).to have_one(:task) }
    it { expect(subject).to have_one(:customer).through(:location) }
    it { expect(subject).to have_many(:comments) }
  end

  context 'Validation' do
    it { expect(subject).to validate_presence_of(:posted_at) }
    it { expect(subject).to validate_presence_of(:location_id) }
    it { expect(subject).to validate_presence_of(:source_id) }
    it { expect(subject).to validate_inclusion_of(:rating).in_range(1..FeedbackServices::RecalculateRating::INNER_RATING).allow_nil(true) }
    context 'with validate_content' do
      before { subject.validate_content = true }
      it { expect(subject).to validate_presence_of(:content) }
    end
  end

  context 'Scopes' do
    it '.ordered' do
      review_1 = create :review, posted_at: 1.minute.ago
      review_2 = create :review, posted_at: 2.minutes.ago
      review_3 = create :review, posted_at: 3.minutes.ago
      expect(Review.ordered.to_a).to eq [review_1, review_2, review_3]
    end

    it '.of_customer' do
      customer = create :customer
      location_1 = create :location, customer: customer
      review_1_1 = create :review, location: location_1

      location_2 = create :location, customer: customer
      review_2_1 = create :review, location: location_2

      location_3 = create :location
      review_3_1 = create :review, location: location_3

      customer_reviews = Review.of_customer(customer).to_a

      expect(customer_reviews).to include review_1_1
      expect(customer_reviews).to include review_2_1

      expect(customer_reviews).to_not include review_3_1
    end

    it '.of_location' do
      location_1 = create :location
      review_1_1 = create :review, location: location_1

      location_2 = create :location
      review_2_1 = create :review, location: location_2

      location_1_reviews = Review.of_location(location_1).to_a
      expect(location_1_reviews).to include review_1_1
      expect(location_1_reviews).to_not include review_2_1
    end

    it '.posted_in' do
      review_1 = create :review, posted_at: 10.days.ago
      review_2 = create :review, posted_at: 4.days.ago
      review_3 = create :review, posted_at: Date.today

      last_reviews = Review.posted_in(7.days.ago..1.day.ago).to_a
      expect(last_reviews).to include review_2
      expect(last_reviews).to_not include review_1
      expect(last_reviews).to_not include review_3
    end
  end
end
