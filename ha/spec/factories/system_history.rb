FactoryGirl.define do
  factory :system_history do
    amounts { { seo: 0.0, ppc: 0.0, social: 0.0 } }
    health { 0.0 }
  end
end
