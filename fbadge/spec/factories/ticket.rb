FactoryGirl.define do
  factory :ticket do
    profile
    ticket_class
    barcode 'barcode'
  end
end
