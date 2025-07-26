FactoryBot.define do
  factory :place do
    sequence(:name) { |n| "name#{n}" }
    sequence(:google_place_id) { |n| "#{n}"}
  end
end