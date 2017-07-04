FactoryGirl.define do
  factory :resolved_item do
    decideable_type 'News'
    decision :saved
  end
end
