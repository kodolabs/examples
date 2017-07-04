FactoryGirl.define do
  factory :host do
    domain
    blog
    blog_type { :wordpress }
    wp_login { FFaker::Lorem.word }
    wp_password { FFaker::Lorem.word }
    author { FFaker::Name.name }
  end
end
