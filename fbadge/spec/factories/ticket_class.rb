FactoryGirl.define do
  factory :ticket_class do
    name { FFaker::Name.first_name }
    quantity_total 5
    event
    sales_start { Time.now }
    sales_end { Time.now + 5.days }
  end
end
