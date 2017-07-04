FactoryGirl.define do
  factory :credit_card do
    patient
    stripe_card_id { 'card_123' }
    last_four { '1234' }
    brand { 'Visa' }
  end
end
