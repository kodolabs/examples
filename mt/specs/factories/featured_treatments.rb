FactoryGirl.define do
  factory :featured_treatment do
    title 'atherectomy'
    header 'Atherectomy'
    slug 'atherectomy'
    top_text 'Top text'
    bottom_text 'Bottom text'
    description FFaker::Lorem.words
    image { File.new(Rails.root.join('app', 'assets', 'images', 'fallback', 'search_result_default.png')) }

    after(:create) do |treatment|
      treatment.featured_treatment_sections << create(:featured_treatment_section)
      treatment.featured_treatment_sections << create(
        :featured_treatment_section,
        title: 'section 2',
        body: FFaker::Lorem.words,
        image: 0
      )
    end
  end
end
