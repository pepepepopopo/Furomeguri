FactoryBot.define do
  factory :itinerary do
    sequence(:title) { |n| "title#{n}" }
    sequence(:subtitle) { |n| "subtitle#{n}" }
    association :user
  end
end
