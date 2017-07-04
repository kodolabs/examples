FactoryGirl.define do
  factory :category do
    sequence :title do |n|
      "Category #{n}"
    end
  end
end
