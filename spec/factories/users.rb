FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user_#{n}@example.com" }
    password { "password" }
    password_confirmation { "password" }
  end

  factory :google_user, class: User do
    sequence(:email) { |n| "TEST#{n}@example.com" }
    password { "testuser123" }
  end
end
