# frozen_string_literal: true

FactoryBot.define do
  factory :search do
    query { 'MyString' }

    trait :invalid do
      query { nil }
    end
  end
end
