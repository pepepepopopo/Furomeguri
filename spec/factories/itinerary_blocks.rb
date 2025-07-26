FactoryBot.define do
  factory :itinerary_block do
    description { "description" }
    association :itinerary
    association :place
  end
end
